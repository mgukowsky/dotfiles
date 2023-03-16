-- Language Server Protocol Configuration

-- Recommended LSP configuration per https://github.com/neovim/nvim-lspconfig
local opts = {noremap = true, silent = true}

local function on_attach(client, bufnr)
  -- Enable completion recommendations from the LSP
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  -- TODO: can/should these go in the opts file?
  vim.g.SuperTabDefaultCompletionType = "<c-x><c-o>" -- Make SuperTab use omnifunc
  vim.opt.completeopt:remove("preview") -- Don't show the stupid Scratch window

  local bufopts = {noremap = true, silent = true, buffer=bufnr}

  -- This will trigger according to the interval set in `vim.opt.updatetime`
  -- TODO: consider power needs...
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      -- Display any diagnostic(s) for the current line, otherwise show generic hover information
      local current_line = vim.api.nvim_win_get_cursor(0)[1]

      -- N.B. lnum starts at 0, so it will be one less than the current line
      if table.getn(vim.diagnostic.get(bufnr, {lnum = current_line - 1})) > 0 then
        vim.diagnostic.open_float({noremap = true, silent = true})
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
end

-- From nvim-lspconfig plugin
local lspconfigs = require("lspconfig")

lspconfigs.clangd.setup({ on_attach = on_attach })
