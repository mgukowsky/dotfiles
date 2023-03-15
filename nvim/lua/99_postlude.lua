-- Closing configuration goes here
vim.cmd.colorscheme("dracula")

-- Make colorschemes use a transparent background
vim.cmd.highlight({"Normal", "guibg=NONE", "ctermbg=NONE"})
vim.cmd.highlight({"LineNr", "guibg=NONE", "ctermbg=NONE"})
