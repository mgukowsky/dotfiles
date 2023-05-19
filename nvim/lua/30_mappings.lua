-- Mappings for various commands go here

-- Corresponds to ":noremap"
local map = vim.keymap.set

-- Easy buffer navigation
map("n", "<C-h>", vim.cmd.bp)
map("n", "<C-l>", vim.cmd.bn)

-- File browser
map("", "<C-n>", vim.cmd.NvimTreeToggle)

-- Telescope shortcuts
local telescope = require('telescope.builtin')
map("n", "<C-p>", telescope.find_files, {})
map("n", "<C-r>", telescope.command_history, {}) -- Same as the bash shortcut

map("n", "<leader>b", telescope.buffers, {})
map("n", "<leader>w", telescope.live_grep, {})
map("n", "<leader>a", telescope.grep_string, {})  -- greps for the word under the cursor
map("n", "<leader>q", telescope.commands, {})
map("n", "<leader><leader>", telescope.builtin, {}) -- meta finder which lists all picker functions

-- Use arrows for resizing splits instead of navigation; vim "hard mode" ;)
map("n", "<Up>", function() vim.cmd.resize(-2) end)

-- '+2' needs to be passed as a string, otherwise the vim side will interpret this as setting
-- the size to 2
map("n", "<Down>", function() vim.cmd.resize("+2") end)
map("n", "<Left>", '<cmd>vertical resize -2<cr>')  -- TODO: vim.cmd.vertical doesn't want to behave...
map("n", "<Right>", '<cmd>vertical resize +2<cr>') -- TODO: ditto...
