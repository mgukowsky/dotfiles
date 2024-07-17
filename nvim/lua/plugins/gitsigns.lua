return {
  'lewis6991/gitsigns.nvim',
  dependencies = { "folke/which-key.nvim" },
  event = "VeryLazy",
  keys = {
    -- Hunk text object
    { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "Select git hunk" }
  },
  opts = {
    numhl = true,
  },
}
