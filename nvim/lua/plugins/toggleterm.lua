return {
  "akinsho/toggleterm.nvim",
  opts = {
    direction = "float",
    float_opts = {
      border = "double",
    },
    on_open = function(term)
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
  },
  keys = {
    -- Similar to VSCode Ctrl+`
    { "<leader>`", function() require("toggleterm").toggle() end, desc = "Toggle terminal" }
  },
}
