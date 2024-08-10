return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Colors defined here will be passed to `on_highlights`
      on_colors = function(colors)
        colors.bright_red = "#FF0000"
      end,
      on_highlights = function(hl, c)
        hl["@label.cpp"] = {
          fg = c.bright_red,
          bold = true,
        }
      end
    },
  }
}
