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
