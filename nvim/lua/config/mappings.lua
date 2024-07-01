-- Corresponds to ":noremap"
local map = vim.keymap.set

-- Easy buffer navigation
map("n", "<C-h>", vim.cmd.bp)
map("n", "<C-l>", vim.cmd.bn)
