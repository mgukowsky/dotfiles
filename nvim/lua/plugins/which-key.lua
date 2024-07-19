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
    opts = {
      preset = "modern",
      notify = true,
      sort = {"alphanum", "mod"},
    },
	}
}
