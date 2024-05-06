-- Language Server Protocol Configuration

local dap = require('dap')
local wk = require("which-key")
local util = require("local.util")
local dap_util = require("local.dap_util")

-- Change the icon that precedes diagnostics, per
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-prefixcharacter-preceding-the-diagnostics-virtual-text

vim.diagnostic.config({
  virtual_text = {
    prefix = '🤯',
  }
})

-- Configuration for vim diagnostics; per
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-diagnostic-symbols-in-the-sign-column-gutter
local signs = { Error = "🤬", Warn = "😬", Hint = "🤔", Info = "🤓" }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Create a DAP session using the first DAP adapter found in the list [cpptools, codelldb, lldb,
-- gdb]
local function run_dap_config(program_path, program_name, args)
  local cfg = {
    cwd = "${workspaceFolder}",
    name = "Launch",
    program = program_path,
    args = args,
    request = "launch",
    stopAtEntry = false,
    preLaunchTask = "default_build",
  }

  local cpptools_path = dap_util.get_cpptools_path()

  if cpptools_path ~= nil and vim.fn.executable(cpptools_path) then
    cfg.type = "cppdbg"
    cfg.linux = {
      MIMode = "gdb",
      miDebuggerPath = "/usr/bin/gdb"
    }
    cfg.osx = {
      MIMode = "lldb",
      miDebuggerPath = "/usr/local/bin/lldb-mi"
    }
    cfg.windows = {
      MIMode = "gdb",
      miDebuggerPath = "C:\\MinGw\\bin\\gdb.exe"
    }
    cfg.setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false
      }
    }
  elseif vim.fn.executable(dap_util.CODELLDB_PATH) then
    cfg.type = "codelldb"
  elseif vim.fn.executable(dap_util.LLDB_PATH) then
    cfg.type = "lldb"
  elseif vim.fn.executable(dap_util.GDB_PATH) then
    cfg.type = "gdb"
    cfg.setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false
      }
    }
  else
    vim.notify("No executable DAP binary found", vim.log.levels.ERROR)
    return
  end

  vim.notify("Running " .. program_name .. " via " .. cfg.type)
  dap.run(cfg)
end

local function cpp_dbg_select()
  local outdir = util.stdout_exec("dirname $(realpath compile_commands.json)")
  -- Get the paths of all executable targets relative to the root of the build directory
  local executables = vim.split(
    util.stdout_exec("ninja -C " .. outdir .. " -t targets all | grep -e 'EXECUTABLE' | cut -d':' -f1"), "\n")

  vim.ui.select(executables,
    { prompt = "Executable to debug:", format_item = function(item) return item end },
    function(choice)
      if choice ~= nil then
        run_dap_config(outdir .. "/" .. choice, choice)
      end
    end)
end

local function cpp_run_gtest_at_cursor()
  local info = util.get_cursor_gtest_info()

  if info == nil then
    vim.notify("Not in a TEST* body", vim.log.levels.ERROR)
    return
  end

  local outdir = util.stdout_exec("dirname $(realpath compile_commands.json)")
  -- ctest can provide us a nice manifest of all the tests mapped to their executables, in JSON format
  local ctest_json = require("dap.ext.vscode").json_decode(
    util.stdout_exec("cd " .. outdir .. " && ctest --show-only=json-v1"))

  local testname = info.suite .. "." .. info.test
  for _, testinfo in ipairs(ctest_json.tests) do
    if testinfo.name == testname then
      local executable = table.remove(testinfo.command, 1)
      run_dap_config(executable, testname, testinfo.command)
      return
    end
  end

  vim.notify("Failed to find test config for " .. testname, vim.log.levels.ERROR)
end

-- Recommended LSP configuration per https://github.com/neovim/nvim-lspconfig
local function on_attach(client, bufnr)
  -- Enable completion recommendations from the LSP
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- TODO: can/should these go in the opts file?
  vim.opt.completeopt:remove("preview") -- Don't show the stupid Scratch window

  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- EDIT: Disabled this as I found it to be too noisy
  -- This will trigger according to the interval set in `vim.opt.updatetime`
  -- TODO: consider power needs...
  if false then
    vim.api.nvim_create_autocmd("CursorHold", {
      buffer = bufnr,
      callback = function()
        -- Display any diagnostic(s) for the current line, otherwise show generic hover information
        local current_line = vim.api.nvim_win_get_cursor(0)[1]

        -- N.B. lnum starts at 0, so it will be one less than the current line
        if #(vim.diagnostic.get(bufnr, { lnum = current_line - 1 })) > 0 then
          vim.diagnostic.open_float({ noremap = true, silent = true })
        else
          vim.lsp.buf.hover(bufopts)
        end
      end
    })
  end

  -- Autoformat on save
  -- Per https://www.jvt.me/posts/2022/03/01/neovim-format-on-save/, but updated to use
  -- vim.lsp.buf.format instead of the deprecated (and removed) vim.lsp.buf.formatting_sync
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = function() vim.lsp.buf.format({ bufnr = bufnr, async = false }) end
  })

  --[[
  -- Create a custom popup menu for various LSP-based actions we can take. I prefer this to
  -- having to create and memorize a shortcut for each of these, most of which I will rarely use
  --]]
  local LSPMenu = "]LSPMenu" -- The leading ']' is a vim-ism for "hidden" menus like this one

  -- Some commands are in the vim.lsp.buf namespace, and some are in the telescope namespace
  local LSP = 0  -- Identifier for LSP functions
  local TEL = 1  -- Identifier for Telescope functions
  local SAGA = 2 -- Identifiers for Lspsaga
  local SAGAREF = 3
  local SAGAIMP = 4

  local function add_menu_entry(entry)
    local namespace = entry[1]
    local methodname = entry[2]

    local cmdstring

    if namespace == LSP then
      cmdstring = ":lua vim.lsp.buf." ..
          string.lower(methodname) .. "({noremap=true, silent=true, buffer=" .. bufnr .. "})<cr>"
    elseif namespace == TEL then
      cmdstring = ":lua require('telescope.builtin').lsp_" .. string.lower(methodname) .. "()<cr>"
    elseif namespace == SAGA then
      cmdstring = ":Lspsaga " .. string.lower(methodname) .. "<cr>"
    elseif namespace == SAGAREF then
      cmdstring = ":Lspsaga finder ref<cr>"
    elseif namespace == SAGAIMP then
      cmdstring = ":Lspsaga finder imp<cr>"
    end

    vim.cmd.amenu({
      LSPMenu .. "." .. methodname,
      -- TODO: can we provide a lua function as the callback instead of the vim cmd string?
      cmdstring
    })
    -- TODO: Use vim.cmd.tmenu to add a tooltip for each entry
  end

  local SEP = "Sep" -- Arbitrary string to represent a menu separator
  local numSep = 1  -- Each separator must have a unique identifier
  for _, entry in pairs({
    -- General info
    { SAGA,    "Hover_Doc" },
    { SAGA,    "Outline" },
    { TEL,     "Definitions" },
    { SAGA,    "Show_Workspace_Diagnostics" },
    { LSP,     "Declaration" },
    { SAGAIMP, "Implementations" },
    { TEL,     "Type_Definitions" },
    { SAGA,    "Peek_Type_Definition" },
    SEP,
    -- Code structure info
    { SAGAREF, "References" },
    { SAGA,    "Incoming_Calls" },
    { SAGA,    "Outgoing_Calls" },
    { TEL,     "Document_Symbols" },
    { TEL,     "Workspace_Symbols" },
    SEP,
    -- Refactoring actions
    { SAGA, "Code_Action" },
    { LSP,  "Rename" },
    { LSP,  "Signature_Help" },
  }) do
    if entry == SEP then
      -- In order to be parsed as a separator, the identifier must be surrounded by -minuses-
      -- The command cannot be empty and must have something other than just whitespace,
      -- so we give it a no-op
      vim.cmd.amenu({ LSPMenu .. ".-" .. SEP .. numSep .. "-", "echo ''" })
      numSep = numSep + 1
    else
      add_menu_entry(entry)
    end
  end

  -- I like this mapping, since C-] will be set to peek definition, and this
  -- <leader> version can be used for all other less-frequently-used options
  vim.keymap.set("n", "<C-]>", "<cmd>Lspsaga peek_definition<cr>")
  wk.register({
    ["<leader>"] = {
      ["]"] = { function() vim.cmd.popup(LSPMenu) end, "LSP Popup menu" },
      n = { function() vim.cmd("Lspsaga outline") end, "Toggle LSP code outline" },
      l = {
        {
          name = "LSP functions",
          a = { function() vim.cmd("Lspsaga code_action") end, "LSP code action" },
          d = { function() require('telescope.builtin').diagnostics({ bufnr = 0 }) end, "Diagnostics" },
          s = { function() require('telescope.builtin').lsp_document_symbols() end, "Document Symbol search" },
          w = { function() require('telescope.builtin').lsp_workspace_symbols() end, "Workspace Symbol search" },
        }
      }
    },
    ["+"] = { function() vim.cmd("Lspsaga hover_doc") end, "Show hover (press twice to focus)" },
    ["["] = {
      d = { function() require("lspsaga.diagnostic"):goto_prev() end, "Prev LSP diagnostic" }
    },
    ["]"] = {
      d = { function() require("lspsaga.diagnostic"):goto_next() end, "Next LSP diagnostic" }
    },
  }, {
    buffer = bufnr,
  })
end

-- Language Server configurations
-- From nvim-lspconfig plugin
local lspconfigs = require("lspconfig")

-- nvim-cmp; needs to be set as the "capabilities for each lsp"
local nvimCmpCapabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfigs.lua_ls.setup({
  on_attach = on_attach,
  capabilities = nvimCmpCapabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
      telemetry = { enable = false }
    },
  }
})

-- Server for LanguageTool. The bin `ltex-ls` needs to be present; see
-- https://www.reddit.com/r/neovim/comments/sdvfwr/comment/hughrfi/
lspconfigs.ltex.setup({
  on_attach = on_attach,
  -- Settings documented at https://valentjn.github.io/ltex/settings.html
  settings = {
    ltex = {
      language = "en-US",
      additionalRules = {
        -- Use ngrams for powerful grammar checking; see
        -- https://dev.languagetool.org/finding-errors-using-n-gram-data.html
        -- for more info. N.B. that the ngram data NEEDS to be unzipped and
        -- MANUALLY placed into the directory specified here!!!
        languageModel = vim.fn.stdpath("data") .. "/ngrams",
      }
    }
  }
})

local json_lsp_cap = vim.lsp.protocol.make_client_capabilities()
json_lsp_cap.textDocument.completion.completionItem.snippetSupport = true
lspconfigs.jsonls.setup({
  on_attach = on_attach,
  capabilities = json_lsp_cap,
})

-- Setup LSPs that don't require any additional configs
-- N.B. that we intentionally omit rust_analyzer from this list; it's handled by rustacean.nvim
for _, lsp_name in pairs({ "cmake", "ruby_lsp", "tsserver" }) do
  lspconfigs[lsp_name].setup({
    on_attach = on_attach,
    capabilities = nvimCmpCapabilities,
  })
end

local function python_on_attach(client, bufnr)
  on_attach(client, bufnr)
  local dap_python = require("dap-python")
  wk.register({
    ["<leader>"] = {
      p = {
        name = "Python functions",
        d = {
          name = "Debug",
          c = { function() dap_python.test_class() end, "Test class under cursor" },
          m = { function() dap_python.test_method() end, "Test method under cursor" },
        }
      }
    }
  }, {
    mode = "n",
    buffer = bufnr,
  })

  wk.register({
    ["<leader>"] = {
      p = {
        name = "Python functions",
        d = { function() dap_python.debug_selection() end, "Debug selection" },
      }
    }
  }, {
    mode = "v",
    buffer = bufnr,
  })
end

lspconfigs.jedi_language_server.setup({
  on_attach = python_on_attach,
  capabilities = nvimCmpCapabilities,
})

local function clangd_on_attach(client, bufnr)
  on_attach(client, bufnr)
  wk.register({
    ["<leader>"] = {
      d = {
        q = {
          d = { function() util.run_if_compile_commands(cpp_dbg_select) end, "Select program to debug" },
          D = { function() util.run_if_compile_commands(cpp_run_gtest_at_cursor) end, "Debug gtest at cursor" },
        }
      }
    },
    ["<F5>"] = { function() util.run_if_compile_commands(cpp_dbg_select) end, "Select program to debug" },
  }, {
    mode = "n",
    buffer = bufnr,
  })
end

lspconfigs.clangd.setup({
  on_attach = clangd_on_attach,
  capabilities = nvimCmpCapabilities,
})

-- Specialization for Rustacean to provide mappings to some of the utility functions
-- that this library provides us
local function rustacean_on_attach(client, bufnr)
  local rlsp = vim.cmd.RustLsp
  on_attach(client, bufnr)
  wk.register({
    ["<leader>"] = {
      d = {
        q = {
          d = { function() rlsp("debuggables") end, "Select program to debug" },
          D = { function() rlsp("debug") end, "Debug target at cursor" },
        },
      },
      l = {
        a = { function() rlsp("codeAction") end, "Code action (Rust)" },
        r = {
          name = "Rust functions",
          c = { function() rlsp("openCargo") end, "Cargo.toml" },
          e = { function() rlsp("explainError") end, "Explain error" },
          E = { function() rlsp("renderDiagnostic") end, "Render diagnostic" },
          -- Only useful if checkOnSave for rust-analyzer is false
          f = { function() rlsp("flyCheck") end, "Fly check (cargo/clippy)" },
          g = { function() rlsp("crateGraph") end, "View crate DAG" },
          m = { function() rlsp("expandMacro") end, "Expand macro" },
          o = { function() rlsp("openDocs") end, "Open docs" },
          p = { function() rlsp("parentModule") end, "Parent module" },
          r = { function() rlsp("runnables") end, "Runnables select" },
          R = { function() rlsp("run") end, "Run target at cursor" },
          s = { function() rlsp("syntaxTree") end, "View syntax tree" },
          t = { function() rlsp("testables") end, "Testables select" },
          x = {
            name = "eXtended functionality",
            a = { function() vim.cmd.RustEmitAsm() end, "View ASM" },
            h = { function() rlsp({ "view", "hir" }) end, "View HIR" },
            i = { function() vim.cmd.RustEmitIr() end, "View LLVM IR" },
            l = { function() rlsp("logFile") end, "rust-analyzer logs" },
            m = { function() rlsp({ "view", "mir" }) end, "View MIR" },
          }
        }
      },
    },
    J = { function() rlsp("joinLines") end, "Join lines" },
    ["+"] = { function() rlsp({ "hover", "actions" }) end, "Show hover (press twice to focus)" },
    ["<F5>"] = { function() rlsp({ "debuggables", bang = true }) end, "Run last debuggable" },

    -- Ctrl+F5; same as Visual Studio mapping
    ["<F29>"] = { function() rlsp({ "runnables", bang = true }) end, "Run last runnable" },
  }, {
    mode = "n",
    buffer = bufnr,
  })

  wk.register({
    ["+"] = { function() rlsp({ "hover", "range" }) end, "Show hover (press twice to focus)" },
  }, {
    mode = "v",
    buffer = bufnr,
  })
end

-- rustacean requires us to setup the Rust LSP separately
vim.g.rustaceanvim = {
  -- Plugin configuration
  tools = {
  },
  -- LSP configuration
  server = {
    on_attach = rustacean_on_attach,
    default_settings = {
      -- rust-analyzer language server configuration
      ['rust-analyzer'] = {
      },
    },
  },
  -- DAP configuration
  -- We handle this in DAP setup earlier, so this can stay commented out unless debugging stops
  -- working
  -- dap = require('dap').configurations.cpp
}
