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

-- whick-key.nvim can create mappings and document them
local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    -- Similar to the bash shortcut
    r = { function() telescope.command_history() end, "Command history" },
    b = { function() telescope.buffers() end, "Show buffers" },
    w = { function() telescope.live_grep() end, "Live grep" },
    a = { function() telescope.grep_string() end, "Grep word under cursor" },
    q = { function() telescope.commands() end, "Vim command search" },
    ["<leader>"] = { function() telescope.builtin() end, "Telescope picker search" },
  },
  -- From gitsigns.nvim; we only add the documentation here
  ["["] = {
    c = { "Prev Git change" }
  },
  ["]"] = {
    c = { "Next Git change" }
  },
})

-- Use arrows for resizing splits instead of navigation; vim "hard mode" ;)
map("n", "<Up>", function() vim.cmd.resize(-2) end)

-- '+2' needs to be passed as a string, otherwise the vim side will interpret this as setting
-- the size to 2
map("n", "<Down>", function() vim.cmd.resize("+2") end)
map("n", "<Left>", '<cmd>vertical resize -2<cr>')  -- TODO: vim.cmd.vertical doesn't want to behave...
map("n", "<Right>", '<cmd>vertical resize +2<cr>') -- TODO: ditto...

-- Prefer osc52 as the default clipboard (g:clipboard gets the highest precedence)
-- Per https://github.com/ojroques/nvim-osc52#using-nvim-osc52-as-clipboard-provider
local function copy(lines, _)
  require('osc52').copy(table.concat(lines, '\n'))
end

local function paste()
  return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
end

vim.g.clipboard = {
  name = 'osc52',
  copy = { ['+'] = copy, ['*'] = copy },
  paste = { ['+'] = paste, ['*'] = paste },
}

-- Now the '+' register will copy to system clipboard using OSC52
vim.keymap.set('n', '<leader>c', '"+y')
vim.keymap.set('n', '<leader>cc', '"+yy')
