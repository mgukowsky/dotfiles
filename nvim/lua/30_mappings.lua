-- Mappings for various commands go here

-- Corresponds to ":noremap"
local map = vim.keymap.set

-- Easy buffer navigation
map("n", "<C-h>", vim.cmd.bp)
map("n", "<C-l>", vim.cmd.bn)

-- File browser
map("", "<C-n>", vim.cmd.NvimTreeToggle)

-- Shortcut for FZF file finder
map("n", "<C-p>", vim.cmd.Files)

-- Searches for the word under the cursor; requires FZF
-- Mappings are based on default vim bindings
map("n", "<leader>w", 'yw:Rg <C-r>"<cr>')
-- Same as above, except matches all characters till the next whitespace
map("n", "<leader>a", 'yW:Rg <C-r>"<cr>')

-- Use arrows for resizing splits instead of navigation; vim "hard mode" ;)
map("n", "<Up>", function() vim.cmd.resize(-2) end)

-- '+2' needs to be passed as a string, otherwise the vim side will interpret this as setting
-- the size to 2
map("n", "<Down>", function() vim.cmd.resize("+2") end)
map("n", "<Left>", '<cmd>vertical resize -2<cr>')  -- TODO: vim.cmd.vertical doesn't want to behave...
map("n", "<Right>", '<cmd>vertical resize +2<cr>') -- TODO: ditto...
