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
    {"<leader>`", function() require("toggleterm").toggle() end, desc = "Toggle terminal"}
  },
}
