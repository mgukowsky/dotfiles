return {
  {
    "folke/lazy.nvim",
    keys = {
      {"<leader>l", function() require("lazy").home() end, desc = "lazy.nvim UI"}
    }
  }
}
