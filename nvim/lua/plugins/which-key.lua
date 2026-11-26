-- which-key.nvim
-- Shows completions for a command as characters are entered
-- (after vim.o.timeoutlen); can also be manually invoked with
-- :WhichKey <partial command...>
-- Also adds hooks in normal mode: will show marks when ` is pressed, and
-- registers when " is pressed, and will also show a menu for spelling suggestions
-- when z= is pressed
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
        notify = true,
        sort = { "alphanum", "mod" },
      })

      -- Group names live in a shared table so the VSCode which-key menu can use them too
      wk.add(require("local.vars").KEY_GROUPS)
    end
  }
}
