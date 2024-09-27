return {
  "akinsho/toggleterm.nvim",
  opts = {
    direction = "float",
    float_opts = {
      border = "double",
    },
  },
  keys = {
    -- Similar to VSCode Ctrl+`
    -- "t" is terminal mode, needed to exit terminal; per
    -- https://www.reddit.com/r/neovim/comments/1bjhadj/comment/kvr43oc
    { "<leader>`", function() require("toggleterm").toggle() end, mode = { "n", "t" },     desc = "Toggle terminal" },
    { "<leader>~", "<cmd>TermSelect<cr>",                         desc = "Select terminal" },
  },
}
