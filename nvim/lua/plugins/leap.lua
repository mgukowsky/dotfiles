-- Search using `s|S` (e.g. `svi` will highlight all matches after the cursor
-- on the window for 'vi', which will be highlighted in yellow with a character,
-- then you can jump to it by pressing that character)
return {
  "ggandor/leap.nvim",
  event = "VeryLazy",
  config = function()
    vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
    vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward" })
    vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { desc = "Leap from window" })

    -- Highlight the leap search area
    -- We hardcode this color to remove the dependency on the vscode UI plugin
    --   local vscPalette = require("vscode.colors").get_colors().vscUiOrange
    vim.api.nvim_set_hl(0, "LeapBackdrop", { fg = '#f28b25' })
  end
}
