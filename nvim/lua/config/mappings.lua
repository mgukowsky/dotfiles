-- Corresponds to ":noremap"
local map = vim.keymap.set

-- Easy buffer navigation
map("n", "<C-h>", vim.cmd.bp, {desc = "Previous buffer"})
map("n", "<C-l>", vim.cmd.bn, {desc = "Next buffer"})
map("n", "<leader>z", function() require("lazy").home() end, {desc = "Lazy UI"})
