-- Vim configuration which should go before everything else
vim.cmd.syntax("on")
vim.opt.encoding = "utf8"
vim.opt.fileencoding = "utf8"

-- Enable the experimental (as of 9/23) Lua module loader (formerly impatient.nvim)
vim.loader.enable()
