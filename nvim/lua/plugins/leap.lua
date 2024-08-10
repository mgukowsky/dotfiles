return {
  "ggandor/leap.nvim",
  event = "VeryLazy",
  dependencies = {
    "Mofiqul/vscode.nvim",
  },
  config = function()
    -- Search using `s|S` (e.g. `svi` will highlight all matches after the cursor
    -- on the window for 'vi', which will be highlighted in yellow with a character,
    -- then you can jump to it by pressing that character)
    local leap = require("leap")
    leap.add_default_mappings()
    -- This allows ";" and "," to repeat motions within leap, but seems to break the functionality of
    -- the keys outside of leap
    -- leap.add_repeat_mappings(";", ",", {
    --   relative_directions = true,
    -- })
    -- Remove the x/X mappings that change the behavior of the key in visual mode
    for _, key in pairs({ "x", "X" }) do
      vim.keymap.del({ "o", "x" }, key)
    end

    -- Highlight the leap search area
    local vscPalette = require("vscode.colors").get_colors()
    vim.api.nvim_set_hl(0, "LeapBackdrop", { fg = vscPalette.vscUiOrange })
  end
}
