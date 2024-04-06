-- Mappings for various commands go here

-- Corresponds to ":noremap"
local map = vim.keymap.set
local del = vim.keymap.del

-- Move visual selections around, from https://youtu.be/w7i4amO_zaE?feature=shared
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Easy buffer navigation
map("n", "<C-h>", vim.cmd.bp)
map("n", "<C-l>", vim.cmd.bn)

-- File browser
map("", "<C-n>", vim.cmd.NvimTreeToggle)

-- Telescope shortcuts
local telescope = require('telescope.builtin')
map("n", "<C-p>", telescope.find_files, {})

local tel_dap = require('telescope').extensions.dap
local dap = require('dap')
local dapui = require('dapui')
local gs = require('gitsigns')
local overseer = require('overseer')

-- which-key.nvim can create mappings and document them
local wk = require("which-key")
wk.register({
  ["<leader>"] = {
    -- Similar to the bash shortcut
    r = { function() telescope.command_history() end, "Command history" },
    b = { function() telescope.buffers() end, "Show buffers" },
    w = { function() telescope.live_grep() end, "Live grep" },
    a = { function() telescope.grep_string() end, "Grep word under cursor" },
    q = { function() telescope.commands() end, "Vim command search" },
    u = { function() vim.cmd("UndotreeToggle") end, "Undotree toggle" },
    ["."] = { function() telescope.symbols() end, "Symbol/emoji search" },
    ["<leader>"] = { function() telescope.builtin() end, "Telescope picker search" },
    d = {
      name = "Debugger (DAP)",
      b = {
        name = "Breakpoints",
        b = { function() dap.toggle_breakpoint() end, "Toggle breakpoint" },
        -- Per https://www.reddit.com/r/neovim/comments/15dtb8l/comment/ju4u4j7
        -- Seems like variables can be referenced directly and don't need the {} wrapping
        --  e.g. `i > 5` is OK;
        c = { function()
          vim.ui.input({ prompt = "Breakpoint condition" },
            function(input) dap.set_breakpoint(input) end)
        end, "Conditional breakpoint" },
        h = { function()
          vim.ui.input({ prompt = "Hit condition (e.g. how many hits before stopping)" },
            function(input) dap.set_breakpoint(nil, input) end)
        end, "Hit conditional breakpoint" },
        -- Requires the {} dereferencing syntax
        --  e.g. `num is {num}` is necessary
        l = { function()
          vim.ui.input({ prompt = "Trace log message" },
            function(input) dap.set_breakpoint(nil, nil, input) end)
        end, "Set breakpoint with log message" },
      },
      c = { function() dap.continue() end, "Start/Continue execution" },
      f = {
        name = "Frames",
        c = { function() dap.focus_frame() end, "Go to current (active) frame" },
        d = { function() dap.down() end, "Go down one frame" },
        r = { function() dap.restart_frame() end, "Restart execution of the current frame" },
        u = { function() dap.up() end, "Go up one frame" }
      },
      n = { function() dap.step_over() end, "Step Over" }, -- "next"
      o = { function() dap.step_out() end, "Step Out" },   -- "finish"
      p = { function() dap.pause() end, "Pause execution" },
      q = {
        name = "DAP commands",
        q = { function() tel_dap.commands() end, "Command search" },
        c = { function() tel_dap.configurations() end, "Select configuration" },
        b = { function() tel_dap.list_breakpoints() end, "List breakpoints" },
        v = { function() tel_dap.variables() end, "List variables" },
        f = { function() tel_dap.frames() end, "List frames" },
      },
      s = { function() dap.step_into() end, "Step Into" },
      t = { function() dapui.toggle() end, "Toggle DAP UI" },
      u = { function() dap.run_to_cursor() end, "Run until current line" }, -- this will temporarily disable breakpoints
      x = { function() dap.terminate() end, "Terminate running program" },
      ["]"] = { function() dapui.eval(nil, { enter = true }) end, "Evaluate variable under cursor/highlight" },
    },
    h = {
      name = "Git Hunk operations",
      b = { function() gs.blame_line() end, "Show blame" },
      B = { function() gs.blame_line({ full = true }) end, "Show full blame" },
      d = { function() gs.toggle_deleted() end, "Toggle show deleted hunks" },
      D = { function() gs.diffthis() end, "Vimdiff current line" },
      p = { function() gs.preview_hunk() end, "Preview hunk" },
      r = { function() gs.undo_stage_buffer() end, "Undo stage buffer" },
      R = { function() gs.reset_buffer() end, "Reset buffer" },
      s = { function() gs.stage_hunk() end, "Stage hunk" },
      S = { function() gs.stage_buffer() end, "Stage buffer" },
      u = { function() gs.reset_hunk() end, "Reset hunk" },
    },
    o = {
      name = "Overseer runner (tasks.json)",
      c = { function() overseer.close() end, "Close" },
      o = { function() overseer.open() end, "Open" },
      r = { function()
        overseer.open()
        overseer.run_template()
      end, "Run" },
      t = { function() overseer.toggle() end, "Toggle" },
    }
  },
  -- From gitsigns.nvim; we only add the documentation here
  ["["] = {
    c = { function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, "Prev Git change" }
  },
  ["]"] = {
    c = { function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, "Next Git change" }
  },
})

-- Use arrows for resizing splits instead of navigation; vim "hard mode" ;)
map("n", "<Up>", function() vim.cmd.resize(-2) end)

-- '+2' needs to be passed as a string, otherwise the vim side will interpret this as setting
-- the size to 2
map("n", "<Down>", function() vim.cmd.resize("+2") end)
map("n", "<Left>", '<cmd>vertical resize -2<cr>')  -- TODO: vim.cmd.vertical doesn't want to behave...
map("n", "<Right>", '<cmd>vertical resize +2<cr>') -- TODO: ditto...

-- Search using `s|S` (e.g. `svi` will highlight all matches after the cursor
-- on the window for 'vi', which will be highlighted in yellow with a character,
-- then you can jump to it by pressing that character)
local leap = require("leap")
leap.add_default_mappings()
-- This allows ";" and "," to repeat motions within leap, but seems to break the functionality of
-- the keys outside of leap
-- leap.add_repeat_mappings(";", ",", {
--   relative_directions = true,
-- })
-- Remove the x/X mappings that change the behavior of the key in visual mode
for _, key in pairs({ "x", "X" }) do
  del({ "o", "x" }, key)
end

-- Highlight the leap search area
local vscPalette = require("vscode.colors").get_colors();
vim.api.nvim_set_hl(0, 'LeapBackdrop', { fg = vscPalette.vscUiOrange })

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
vim.keymap.set('n', '<leader>y', '"+y')
vim.keymap.set('n', '<leader>yy', '"+yy')

-- Alternative Visual Studio-style debugger mappings
map("n", "<F5>", function() dap.continue() end)
map("n", "<F7>", function()
  overseer.open()
  overseer.run_template()
end)
map("n", "<F9>", function() dap.toggle_breakpoint() end)
map("n", "<F10>", function() dap.step_over() end)
map("n", "<F11>", function() dap.step_into() end)
map("n", "<F12>", function() dap.step_out() end)
