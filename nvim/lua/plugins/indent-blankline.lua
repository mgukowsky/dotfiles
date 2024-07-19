-- Show vertical lines for each indent level
return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  opts = {
    indent = {
      char = "¦",
    },
    scope = {
      enabled = false,
    },
  },
}
