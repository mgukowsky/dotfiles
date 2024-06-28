-- Corresponds to the `:set` command
local opt = vim.opt

opt.autoindent = true -- Preserve previous line's indentation when staring a new line
opt.background = "dark"
opt.cindent = false -- Don't use C indentation rules

--[[
-- Makes y and p commands use the global copy/paste buffer.
--
-- N.B. this probably won't play well with vim sessions over SSH. To copy in
-- such scenarios, either X11 forward hold SHIFT while click-dragging the mouse
-- to select and then copy-paste (can also enter `:set nonumber` to remove line
-- numbers first)
--]]
opt.clipboard:append("unnamedplus")

opt.completeopt = { "menu", "menuone", "noselect" } -- Trigger menu for a single entry

opt.colorcolumn = { 100 } -- Rulers
opt.cursorline = true -- Highlight the current line as needed
opt.expandtab = true -- Use spaces instead of tabs
opt.exrc = true -- Load external rc files, if present
opt.hidden = true -- Remove warnings when switching btwn buffers that haven't yet been written out
opt.hlsearch = true -- Highlight search match
opt.incsearch = true -- Match search as you type
opt.jumpoptions = "stack" -- Make jumplist function like a browser forward/back button

-- Characters used to represent whitespace
-- N.B. use the command `:set list` or `vim.opt.list = true` to see these
opt.list = false -- Don't show these whitespace characters
opt.listchars = { tab = ">-", space = "·", trail = "○", eol = "↲", nbsp = "▯" }

opt.mouse = "a" -- Mouse support
opt.number = true -- Show line numbers
opt.path:append("**") -- Better searching and tab completion for files

-- Commenting this out as it appears to screw with certain popups like the LSP menu
--opt.pumblend = 15         -- Transparent menus

-- Useful for quickly navigating up and down (e.g. 10j to go to the 10th line down), but somewhat
-- redundant with leap.nvim
-- opt.relativenumber = true -- Show line numbers relative to the current line number (useful for quick vertical navigation, e.g. 5j)
opt.scrolloff = 4 -- Min # of lines to keep around the cursor
opt.secure = true -- Don't allow untrusted scripts to execute
opt.signcolumn = "yes:1" -- Always show the sign column and set the width to 1 character
opt.shiftwidth = 2 -- tab config
opt.showcmd = true -- Show previous command
opt.showmatch = true
opt.smartindent = false
opt.softtabstop = 2 -- # of tab spaces in insert mode
opt.tabstop = 2 -- # of tab spaces
opt.termguicolors = true -- Use UI colors if supported

-- Set the timeout for keycode delays (i.e. for quick ESC responses)
-- See https://www.johnhawthorn.com/2012/09/vi-escape-delays/
opt.timeoutlen = 1000
opt.ttimeoutlen = 10

opt.title = true -- Set the title of the window to the file being edited
opt.updatetime = 1000 -- Update buffers every second
opt.wrap = true -- Wrap text
opt.wildmenu = true -- Better searching and tab completion for files

-- A few options are managed through global variables
local g = vim.g -- Corresponds to "g:" variables
g.t_co = 256 -- Corresponds to vim's `t_Co`
g.base16colorspace = 256

-- Configuration for plugins; mainly managed through global variables

-- Make limelight OK with our transparent background
g.limelight_conceal_ctermfg = "DarkGray"
g.limelight_conceal_guifg = "DarkGray"

-- Prevent vim-markdown from hiding characters
g.markdown_syntax_conceal = 0

-- Show quote characters in JSON files
g.vim_json_conceal = 0

