return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  keys = {
    { "<C-n>", vim.cmd.NvimTreeToggle, desc = "Toggle NvimTree" }
  },
  opts = {
    disable_netrw = true,
    filters = {
      dotfiles = false,
    },
    view = {
      float = {
        enable = true,
        quit_on_focus_loss = false,
      },
    },
  },
  init = function()
    -- Plugin recommends to set these as early as possible
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end
}
