-- Various settings are managed here

-- Corresponds to the `:set` command
local opt = vim.opt

opt.autoindent = true -- Preserve previous line's indentation when staring a new line
opt.background = "dark"
opt.cindent = false   -- Don't use C indentation rules

--[[
-- Makes y and p commands use the global copy/paster buffer.
--
-- N.B. this probably won't play well with vim sessions over SSH. To copy in
-- such scenarios, either X11 forward hold SHIFT while click-dragging the mouse
-- to select and then copy-paste (can also enter `:set nonumber` to remove line
-- numbers first)
--]]
opt.clipboard:append("unnamedplus")

opt.colorcolumn = { 100 } -- Rulers
opt.cursorline = true     -- Highlight the current line as needed
opt.expandtab = true      -- Use spaces instead of tabs
opt.exrc = true           -- Load external rc files, if present
opt.hidden = true         -- Remove warnings when switching btwn buffers that haven't yet been written out
opt.hlsearch = true       -- Highlight search match
opt.incsearch = true      -- Match search as you type

-- Characters used to represent whitespace
-- N.B. use the command `:set list` or `vim.opt.list = true` to see these
opt.list = false -- Don't show these whitespace characters
opt.listchars = { tab = ">-", space = "·", trail = "○", eol = "↲", nbsp = "▯" }

opt.mouse = "a"         -- Mouse support
opt.number = true       -- Show line numbers
opt.path:append("**")   -- Better searching and tab completion for files
opt.scrolloff = 4       -- Min # of lines to keep around the cursor
opt.secure = true       -- Don't allow untrusted scripts to execute
opt.signcolumn = "auto" -- Show the sign column (used by the marks.nvim plugin, for example)
opt.shiftwidth = 2      -- tab config
opt.showcmd = true      -- Show previous command
opt.showmatch = true
opt.smartindent = false
opt.softtabstop = 2      -- # of tab spaces in insert mode
opt.tabstop = 2          -- # of tab spaces
opt.termguicolors = true -- Use UI colors if supported

-- Set the timeout for keycode delays (i.e. for quick ESC responses)
-- See https://www.johnhawthorn.com/2012/09/vi-escape-delays/
opt.timeoutlen = 1000
opt.ttimeoutlen = 10

opt.title = true      -- Set the title of the window to the file being edited
opt.updatetime = 1000 -- Update buffers every second
opt.wildmenu = true   -- Better searching and tab completion for files

-- Configuration for vim diagnostics
vim.cmd("sign define DiagnosticSignError text=🤬 texthl=DiagnosticSignError linehl= numhl=")
vim.cmd("sign define DiagnosticSignWarn text=😬 texthl=DiagnosticSignWarn linehl= numhl=")
vim.cmd("sign define DiagnosticSignInfo text=👀 texthl=DiagnosticSignInfo linehl= numhl=")
vim.cmd("sign define DiagnosticSignHint text=🤔 texthl=DiagnosticSignHint linehl= numhl=")

-- A few options are managed through global variables
local g = vim.g -- Corresponds to "g:" variables
g.t_co = 256    -- Corresponds to vim's `t_Co`
g.base16colorspace = 256

-- Configuration for plugins; mainly managed through global variables

-- Vim-airline config
g["airline#extensions#tabline#enabled"] = 1 -- [] are necessary for fields containing '#'
g.airline_powerline_fonts = 1
g.airline_theme = "hybrid"
g.hybrid_custom_term_colors = 1
g.hybrid_reduced_contrast = 1

-- NERDTree
g.NERDTreeShowHidden = 1

-- Make limelight OK with our transparent background
g.limelight_conceal_ctermfg = "DarkGray"
g.limelight_conceal_guifg = "DarkGray"

-- gitsigns.nvim (replaces GitGutter)
require('gitsigns').setup({
  numhl = true,
  -- Install recommended keybindings per https://github.com/lewis6991/gitsigns.nvim
  -- Very similar to what was in GitGutter
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then return ']c' end
      vim.schedule(function() gs.next_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    map('n', '[c', function()
      if vim.wo.diff then return '[c' end
      vim.schedule(function() gs.prev_hunk() end)
      return '<Ignore>'
    end, { expr = true })

    -- Actions
    map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map({ 'n', 'v' }, '<leader>hu', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map('n', '<leader>hr', gs.undo_stage_hunk)
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function() gs.blame_line { full = true } end)
    map('n', '<leader>tb', gs.toggle_current_line_blame)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function() gs.diffthis('~') end)
    map('n', '<leader>td', gs.toggle_deleted)

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
})

-- nvim-cursorline
require('nvim-cursorline').setup({
  cursorline = {
    enable = false
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
})

-- marks.nvim
require('marks').setup({
  -- Don't install mappings from the plugin
  default_mappings = true,
  --[[
  -- . is the position of the last change
  -- ' is the is the position of the cursor prior to the last jump
  -- ^ is the position of the cursor when it last exited Insert mode
  --]]
  builtin_marks = { ".", "'", "^" }
})
