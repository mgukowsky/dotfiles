-- Various settings are managed here

-- We start with some bits that don't have an obvious lua equivalent
-- TODO: Do all of these in lua
vim.cmd([[
set t_Co=256

let base16colorspace=256
if(has("termguicolors"))
  set termguicolors
endif
]])

-- Corresponds to the `:set` command
local opt = vim.opt

opt.autoindent = true -- Preserve previous line's indentation when staring a new line
opt.background = "dark"
opt.cindent = false -- Don't use C indentation rules

--[[
-- Makes y and p commands use the global copy/paster buffer.
--
-- N.B. this probably won't play well with vim sessions over SSH. To copy in
-- such scenarios, either X11 forward hold SHIFT while click-dragging the mouse
-- to select and then copy-paste (can also enter `:set nonumber` to remove line
-- numbers first)
--]]
opt.clipboard:append("unnamedplus")

opt.colorcolumn = {100} -- Rulers
opt.cursorline = true -- Highlight the current line as needed
opt.expandtab = true -- Use spaces instead of tabs
opt.exrc = true -- Load external rc files, if present
opt.hidden = true -- Remove warnings when switching btwn buffers that haven't yet been written out
opt.hlsearch = true -- Highlight search match
opt.incsearch = true -- Match search as you type

-- Characters used to represent whitespace
-- N.B. use the command `:set list` or `vim.opt.list = true` to see these
opt.list = false -- Don't show these whitespace characters
opt.listchars = { tab = ">-", space = "·", trail = "○", eol = "↲", nbsp = "▯" }

opt.mouse = "a" -- Mouse support
opt.number = true -- Show line numbers
opt.path:append("**") -- Better searching and tab completion for files
opt.secure = true -- Don't allow untrusted scripts to execute
opt.shiftwidth = 2 -- tab config
opt.showcmd = true -- Show previous command
opt.showmatch = true 
opt.smartindent = false
opt.softtabstop = 2 -- tab config
opt.tabstop = 2 -- tab config

-- Set the timeout for keycode delays (i.e. for quick ESC responses)
-- See https://www.johnhawthorn.com/2012/09/vi-escape-delays/
opt.timeoutlen = 1000
opt.ttimeoutlen = 10

opt.title = true -- Set the title of the window to the file being edited
opt.updatetime = 1000 -- Update buffers every second (allows GitGutter to refresh)
opt.wildmenu = true -- Better searching and tab completion for files

-- Configuration for plugins; mainly managed through global variables
local g = vim.g -- Corresponds to "g:" variables

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

-- GitGutter configuration
vim.cmd.highlight({"GitGutterAdd", "guifg=#00ff00", "ctermfg=10"})
vim.cmd.highlight({"GitGutterChange", "guifg=#ffff00", "ctermfg=11"})
vim.cmd.highlight({"GitGutterDelete", "guifg=#ff0000", "ctermfg=9"})
g.gitgutter_sign_added = '++'
g.gitgutter_sign_modified = 'ΔΔ'
g.gitgutter_sign_removed = '--'
g.gitgutter_sign_removed_first_line = '^^'
g.gitgutter_sign_modified_removed = '~x'

