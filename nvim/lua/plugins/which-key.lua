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

    -- N.B. this is equivalent to
    -- `config = function() require('which-key').setup()`
    -- If the `opts` key is provided, that would be passed as `setup(opts)`
    config = true,
	}
}
