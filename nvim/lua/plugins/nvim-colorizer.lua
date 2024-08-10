-- Highlight colorcodes as the actual color
return {
  "NvChad/nvim-colorizer.lua",
  -- Seems to break w/o this
  lazy = false,
  opts = {
    user_default_options = {
      -- Don't show for color keywords like `red` or `blue`
      names = false,
      -- Default mode is 'background', which sets the background color of the color code
      mode = "virtualtext",
      -- We choose a slightly larger nerd-font character than the small default suqare
      virtualtext = "",
      virtualtext_inline = true,
    }
  }
}
