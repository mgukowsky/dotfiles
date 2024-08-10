-- Language Server Protocol Configuration

-- Change the icon that precedes diagnostics, per
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-prefixcharacter-preceding-the-diagnostics-virtual-text

vim.diagnostic.config({
	virtual_text = {
		prefix = "🤯",
	},
})

-- Configuration for vim diagnostics; per
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-diagnostic-symbols-in-the-sign-column-gutter
local signs = { Error = "🤬", Warn = "😬", Hint = "🤔", Info = "🤓" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Recommended LSP configuration per https://github.com/neovim/nvim-lspconfig
local function on_attach(_, bufnr)
  local wk = require("which-key")
	-- Enable completion recommendations from the LSP
	vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })

	-- TODO: can/should these go in the opts file?
	vim.opt.completeopt:remove("preview") -- Don't show the stupid Scratch window

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
					vim.lsp.buf.hover()
				end
			end,
		})
	end

	--[[
  -- Create a custom popup menu for various LSP-based actions we can take. I prefer this to
  -- having to create and memorize a shortcut for each of these, most of which I will rarely use
  --]]
	local LSPMenu = "]LSPMenu" -- The leading ']' is a vim-ism for "hidden" menus like this one

	-- Some commands are in the vim.lsp.buf namespace, and some are in the telescope namespace
	local LSP = 0 -- Identifier for LSP functions
	local TEL = 1 -- Identifier for Telescope functions
	local SAGA = 2 -- Identifiers for Lspsaga
	local SAGAREF = 3
	local SAGAIMP = 4

	local function add_menu_entry(entry)
		local namespace = entry[1]
		local methodname = entry[2]

		local cmdstring

		if namespace == LSP then
			cmdstring = ":lua vim.lsp.buf."
				.. string.lower(methodname)
				.. "({noremap=true, silent=true, buffer="
				.. bufnr
				.. "})<cr>"
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
			cmdstring,
		})
		-- TODO: Use vim.cmd.tmenu to add a tooltip for each entry
	end

	local SEP = "Sep" -- Arbitrary string to represent a menu separator
	local numSep = 1 -- Each separator must have a unique identifier
	for _, entry in pairs({
		-- General info
		{ SAGA, "Hover_Doc" },
		{ SAGA, "Outline" },
		{ TEL, "Definitions" },
		{ SAGA, "Show_Workspace_Diagnostics" },
		{ LSP, "Declaration" },
		{ SAGAIMP, "Implementations" },
		{ TEL, "Type_Definitions" },
		{ LSP, "TypeHierarchy" },
		{ SAGA, "Peek_Type_Definition" },
		SEP,
		-- Code structure info
		{ SAGAREF, "References" },
		{ SAGA, "Incoming_Calls" },
		{ SAGA, "Outgoing_Calls" },
		{ TEL, "Document_Symbols" },
		{ TEL, "Workspace_Symbols" },
		SEP,
		-- Refactoring actions
		{ SAGA, "Code_Action" },
		{ LSP, "Rename" },
		{ LSP, "Signature_Help" },
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
	vim.keymap.set("n", "<C-]>", "<cmd>Lspsaga peek_definition<cr>", {desc = "Peek definition"})
  wk.add({
    {
		  buffer = bufnr,
      {"+", function() vim.cmd("Lspsaga hover_doc") end, desc = "Show hover (press twice to focus)"},

      {"<leader>]", function() vim.cmd.popup(LSPMenu) end, desc = "LSP Popup menu"},
      {"<leader>n", function() vim.cmd("Lspsaga outline") end, desc = "Toggle LSP code outline"},

      {"<leader>l", group = "LSP functions"},
      {"<leader>la", function() vim.cmd("Lspsaga code_action") end, desc = "LSP code action"},
      {"<leader>ld", function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end, desc = "Diagnostics"},
      {"<leader>li", function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, desc = "Toggle Inlay Hints"},
      {"<leader>ls", function() require("telescope.builtin").lsp_document_symbols() end, desc = "Document Symbol search"},
      {"<leader>lw", function() require("telescope.builtin").lsp_workspace_symbols() end, desc = "Workspace Symbol search"},

    }
  })

	-- Movement mappings
	local next_diag_repeat, prev_diag_repeat = require("nvim-treesitter.textobjects.repeatable_move").make_repeatable_move_pair(function()
		require("lspsaga.diagnostic"):goto_next()
	end, function()
		require("lspsaga.diagnostic"):goto_prev()
	end)

  local function run_if_diagnostics(fn)
    if vim.tbl_isempty(vim.diagnostic.get(0)) then
      -- Based on the equivalent message shown by gitsigns when there are no hunks
      vim.api.nvim_echo({ { 'No diagnostics', 'WarningMsg' } }, false, {})
    else
      fn()
    end
  end
  wk.add({
    {
	    mode = { "n", "x", "o" },
      { "[d", function() run_if_diagnostics(prev_diag_repeat) end, desc = "Prev LSP diagnostic" },
      { "]d", function() run_if_diagnostics(next_diag_repeat) end, desc = "Next LSP diagnostic" },
    },
  })
end

local function get_lsp_caps()
  -- nvim-cmp; needs to be set as the "capabilities for each lsp"
  return require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
end

local function setup_lsps()
  -- From nvim-lspconfig plugin
  local lspconfigs = require("lspconfig")

  lspconfigs.lua_ls.setup({
    on_attach = on_attach,
    capabilities = get_lsp_caps(),
    settings = {
      -- empty; config handled elsewhere by lazydev.nvim
    },
  })

  -- Server for LanguageTool. The bin `ltex-ls` needs to be present; see
  -- https://www.reddit.com/r/neovim/comments/sdvfwr/comment/hughrfi/
  lspconfigs.ltex.setup({
    on_attach = on_attach,
    capabilities = get_lsp_caps(),
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
        },
      },
    },
  })

  -- Schema configs per https://www.arthurkoziel.com/json-schemas-in-neovim/
  local json_lsp_cap = get_lsp_caps()
  json_lsp_cap.textDocument.completion.completionItem.snippetSupport = true
  lspconfigs.jsonls.setup({
    on_attach = on_attach,
    capabilities = json_lsp_cap,
    settings = {
      json = {
        schemas = require("schemastore").json.schemas(),
        validate = { enable = true },
      },
    },
  })

  lspconfigs.yamlls.setup(require("yaml-companion").setup({
    lspconfig = {
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        require("which-key").add({
          {
            buffer = bufnr,
            {"<leader>lx", function() require("telescope").extensions.yaml_schema.yaml_schema() end, desc = "Select YAML schema"},
          }
        })
      end,
      capabilities = get_lsp_caps(),
      settings = {
        yaml = {
          validate = true,
          -- Using schemastore seems to not work for this atm...
          -- schemaStore = {
          -- 	enable = false,
          -- 	url = "",
          -- },
          -- schemas = require("schemastore").yaml.schemas(),
        },
      },
    },
  }))
  require("telescope").load_extension("yaml_schema")

---@diagnostic disable-next-line: unused-function
  local function clangd_on_attach(client, bufnr)
    on_attach(client, bufnr)

    local util = require("local.util")
    local cpp_util = require("local.cpp_util")

    require("which-key").add({
      {
        buffer = bufnr,
        {"<leader>dqd", function() util.run_if_compile_commands(cpp_util.dbg_select) end, desc = "Select program to debug"},
        {"<leader>dqD", function() util.run_if_compile_commands(cpp_util.run_gtest_at_cursor) end, desc = "Debug gtest at cursor"},
        {"<F5>", function() util.run_if_compile_commands(cpp_util.dbg_select) end, desc = "Select program to debug"},
        -- Shift+F5
        {"<F17>", function()
          util.run_if_compile_commands(function()
            cpp_util.dbg_select({ enter_args = true })
          end)
        end, desc = "Select program (w/args) to debug"},
      }
    })
  end

  lspconfigs.clangd.setup({
    on_attach = clangd_on_attach,
    capabilities = get_lsp_caps(),
  })

  -- Specialization for Rustacean to provide mappings to some of the utility functions
  -- that this library provides us.
  -- N.B. that this plugin is already lazy and this the `RustLsp` command will be available
  local function rustacean_on_attach(client, bufnr)
    local rlsp = vim.cmd.RustLsp
    on_attach(client, bufnr)
    local wk = require("which-key")
    wk.add({
      {
        buffer = bufnr,
        {"<leader>dqd", function() rlsp("debuggables") end, desc = "Select program to debug"},
        {"<leader>dqD", function() rlsp("debug") end, desc = "Debug target at cursor"},
        {"<leader>la", function() rlsp("codeAction") end, desc = "Code action (Rust)"},
        {"<leader>lrc", function() rlsp("openCargo") end, desc = "Cargo.toml"},
        {"<leader>lre", function() rlsp("explainError") end, desc = "Explain error"},
        {"<leader>lrE", function() rlsp("renderDiagnostic") end, desc = "Render diagnostic"},
        {"<leader>lrf", function() rlsp("flyCheck") end, desc = "Fly check (cargo/clippy)"},
        {"<leader>lrg", function() rlsp("crateGraph") end, desc = "View crate DAG"},
        {"<leader>lrm", function() rlsp("expandMacro") end, desc = "Expand macro"},
        {"<leader>lro", function() rlsp("openDocs") end, desc = "Open docs"},
        {"<leader>lrp", function() rlsp("parentModule") end, desc = "Parent module"},
        {"<leader>lrr", function() rlsp("runnables") end, desc = "Runnables select"},
        {"<leader>lrR", function() rlsp("run") end, desc = "Run target at cursor"},
        {"<leader>lrs", function() rlsp("syntaxTree") end, desc = "View syntax tree"},
        {"<leader>lrt", function() rlsp("testables") end, desc = "Testables select"},
        {"<leader>lrxa", function() vim.cmd.RustEmitAsm() end, desc = "View ASM"},
        {"<leader>lrxh", function() rlsp({ "view", "hir" }) end, desc = "View HIR"},
        {"<leader>lrxi", function() vim.cmd.RustEmitIr() end, desc = "View LLVM IR"},
        {"<leader>lrxl", function() rlsp("logFile") end, desc = "rust-analyzer logs"},
        {"<leader>lrxm", function() rlsp({ "view", "mir" }) end, desc = "View MIR"},
        {"J", function() rlsp("joinLines") end, desc = "Join lines"},
        {"+", function() rlsp({ "hover", "actions" }) end, desc = "Show hover (press twice to focus)"},
        {"<F5>", function() rlsp({ "debuggables", bang = true }) end, desc = "Run last debuggable"},
        -- Ctrl+F5; same as Visual Studio mapping
        {"<F29>", function() rlsp({ "runnables", bang = true }) end, desc = "Run last runnable"},
      }
    })

    wk.add({
      {
        buffer = bufnr,
        mode = "v",
        {"+", function() rlsp({ "hover", "range" }) end, desc = "Show hover (press twice to focus)"},
      }
    })
  end

  -- rustacean requires us to setup the Rust LSP separately
  vim.g.rustaceanvim = {
    -- Plugin configuration
    tools = {},
    -- LSP configuration
    server = {
      on_attach = rustacean_on_attach,
      default_settings = {
        -- rust-analyzer language server configuration
        ["rust-analyzer"] = {},
      },
    },
  }

  -- Setup LSPs that don't require any additional configs
  -- N.B. that we intentionally omit rust_analyzer from this list; it's handled by rustacean.nvim
  for _, lsp_name in pairs({ "cmake", "glsl_analyzer", "jedi_language_server", "ruby_lsp", "taplo", "tsserver" }) do
    lspconfigs[lsp_name].setup({
      on_attach = on_attach,
      capabilities = get_lsp_caps(),
    })
  end
end

return {
  "neovim/nvim-lspconfig",
  config = function()
    setup_lsps()
  end,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "folke/which-key.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/cmp-nvim-lsp",
    "b0o/schemastore.nvim",

    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
        library = {
          -- See the configuration section for more details
          -- Load luvit types when the `vim.uv` word is found
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
    },
    { "Bilal2453/luvit-meta", ft = "lua", lazy = true }, -- optional `vim.uv` typings
    -- setup for this plugin is handled by the yamlls setup
    -- "someone-stole-my-name/yaml-companion.nvim",
    {
      "nvimdev/lspsaga.nvim",
      opts = {
        callhierarchy = {
          keys = {
            edit = "<CR>",
            toggle_or_req = "<Space>",
          },
        },
        code_action = {
          extend_gitsigns = true,
          num_shortcut = true,
          show_server_name = true,
        },
        definition = {
          width = 0.8,
          height = 0.5,
          keys = {
            edit = "<CR>",
          },
        },
        diagnostic = {
          extend_relatedInformation = true,
        },
        finder = {
          keys = {
            toggle_or_open = "<CR>",
          },
          max_height = 0.8,
        },
        implement = {
          enable = true,
          sign = true,
        },
        lightbulb = {
          debounce = 3000, -- lightbulb can be noisy and/or cause performance issues, so let's throttle it
        },
        outline = {
          close_after_jump = false,
          layout = "float",
          keys = {
            toggle_or_jump = "<CR>",
          },
          max_height = 0.8,
          win_width = 45,
        },
        symbol_in_winbar = {
          enable = true,
        },
        ui = {
          border = "rounded",
        },
      },
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "VeryLazy",
        opts = {
          hint_prefix = "🧐",
          select_signature_key = "<C-S>",
        }
    },
    {
      'mrcjkb/rustaceanvim',
      lazy = false, -- This plugin is already lazy
    },
  }
}
