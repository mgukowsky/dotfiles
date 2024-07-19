-- Autocommands live here

-- Corresponds to ":au"
local au = vim.api.nvim_create_autocmd

-- Enable spellchecking for specific filetypes
-- First, though, we have to create the directory for any custom words (e.g. any we add with `zg`)
local SPELLDIR = vim.fn.stdpath("data") .. "/spell"
if vim.fn.isdirectory(SPELLDIR) == 0 then
	vim.fn.mkdir(SPELLDIR)
end

au("FileType", {
	pattern = "markdown,text",
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en_us"
		vim.opt_local.spellfile = SPELLDIR .. "/en.utf-8.add"
	end,
})

au("TextYankPost", {
	pattern = "*",
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- File types for rare extensions
local function setft(ext, syntax) -- Set syntax association for a given filetype
	au({ "BufNewFile", "BufReadPost" }, {
		pattern = { ext },
		callback = function()
			vim.opt.ft = syntax
		end,
	})
end

setft("*.manifest", "xml")
setft("*.frag", "glsl")
setft("*.vert", "glsl")
setft("*.zsh-theme", "sh")
setft(".clang-format", "yaml")
setft(".gitmessage", "gitcommit")
