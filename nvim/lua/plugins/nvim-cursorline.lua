return {
  'yamatsum/nvim-cursorline',
  lazy = false, -- doesn't work if lazy loaded :/
  opts = {
    cursorline = {
      enable = false,
    },
    cursorword = {
      enable = true,
      min_length = 3,
      hl = { underline = true },
    },
  },
}
