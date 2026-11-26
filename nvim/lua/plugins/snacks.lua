return {
  "folke/snacks.nvim",
  -- snacks must load eagerly: it defines the global `Snacks` and hooks startup events
  lazy = false,
  priority = 1000,
  opts = {
    dim = {
      animate = { enabled = false },
    },
    zen = {
      toggles = { dim = true },
      center = true,
      show = { statusline = false, tabline = false },
      -- blend = 0 makes the backdrop fully opaque, hiding everything behind the zen window
      win = { style = "zen", backdrop = { blend = 0 } },
    },
  },
  keys = {
    { "<leader>f", function() Snacks.zen() end, desc = "Toggle Zen mode" },
  }
}
