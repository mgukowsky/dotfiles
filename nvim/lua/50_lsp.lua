-- Language Server Protocol Configuration

-- Change the icon that precedes diagnostics, per
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-prefixcharacter-preceding-the-diagnostics-virtual-text

vim.diagnostic.config({
  virtual_text = {
    prefix = '🤯',
  }
})

-- Configuration for vim diagnostics. The nvim-lspconfig wiki has a way to do this
-- programmatically, however using `vim.cmd` seems to be the only way to make nvim accept the
-- emojis as text
vim.cmd("sign define DiagnosticSignError text=🤬 texthl=DiagnosticSignError linehl= numhl=")
vim.cmd("sign define DiagnosticSignWarn text=😬 texthl=DiagnosticSignWarn linehl= numhl=")
vim.cmd("sign define DiagnosticSignInfo text=👀 texthl=DiagnosticSignInfo linehl= numhl=")
vim.cmd("sign define DiagnosticSignHint text=🤔 texthl=DiagnosticSignHint linehl= numhl=")

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
  local function add_menu_entry(methodname)
    vim.cmd.amenu({
      LSPMenu .. "." .. methodname,
      -- TODO: can we provide a lua function as the callback instead of the vim cmd string?
      ":lua vim.lsp.buf." .. string.lower(methodname) .. "({noremap=true, silent=true, buffer=" .. bufnr .. "})<cr>"
    })
    -- TODO: Use vim.cmd.tmenu to add a tooltip for each entry
  end

  local SEP = "Sep" -- Arbitrary string to represent a menu separator
  local numSep = 1  -- Each separator must have a unique identifier
  for _, entry in pairs({
    -- General info
    "Hover",
    "Declaration",
    "Definition",
    "Implementation",
    "Type_Definition",
    SEP,
    -- Refactoring actions
    "Code_Action",
    "Rename",
    "Signature_Help",
    SEP,
    -- Code structure info
    "References",
    "Document_Symbol",
    "Workspace_Symbol"
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

  -- I like this mapping, since C-] will be set to the LSP tagfunc (usually definition), and this
  -- <leader> version can be used for all other less-frequently-used options
  vim.keymap.set("n", "<leader>]", function() vim.cmd.popup(LSPMenu) end)

  -- Also add the ability to move between diagnostics
  local opts = { noremap = true, silent = true }
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
end

-- Language Server configurations
-- From nvim-lspconfig plugin
local lspconfigs = require("lspconfig")

-- nvim-cmp; needs to be set as the "capabilities for each lsp"
local nvimCmpCapabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfigs.clangd.setup({ on_attach = on_attach, capabilities = nvimCmpCapabilities })

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
