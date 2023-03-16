-- Language Server Protocol Configuration

-- Recommended LSP configuration per https://github.com/neovim/nvim-lspconfig
local function on_attach(client, bufnr)
  -- Enable completion recommendations from the LSP
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- TODO: can/should these go in the opts file?
  vim.b.SuperTabDefaultCompletionType = "<c-x><c-o>" -- Make SuperTab use omnifunc
  vim.opt.completeopt:remove("preview")              -- Don't show the stupid Scratch window

  local bufopts = { noremap = true, silent = true, buffer = bufnr }

  -- This will trigger according to the interval set in `vim.opt.updatetime`
  -- TODO: consider power needs...
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

  -- Autoformat on save
  -- Per https://www.jvt.me/posts/2022/03/01/neovim-format-on-save/
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = vim.lsp.buf.formatting_sync -- Prob no harm in this being sync...
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

  for _, entry in pairs({
    "Declaration", "Definition", "Implementation", "Type_Definition", "Code_Action", "Rename",
    "Signature_Help", "References", "Document_Symbol", "Workspace_Symbol"
  }) do
    add_menu_entry(entry)
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
lspconfigs.clangd.setup({ on_attach = on_attach })
lspconfigs.lua_ls.setup({
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false }
    },
  }
})
