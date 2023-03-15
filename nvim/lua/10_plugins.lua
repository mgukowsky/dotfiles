-- Logic for plugin managers goes here

-- Lua adapter for vim-plug
-- Adapted from https://www.reddit.com/r/neovim/comments/xvbhs2/how_to_use_vim_plug_with_initlua/
local Plug = vim.fn["plug#"]
vim.call("plug#begin", vim.fn.stdpath("data").."/plugged")

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

-- Automatic completion for braces and other open/close characters
Plug 'townk/vim-autoclose'
Plug 'ryanoasis/vim-devicons'

-- Color schemes
vim.cmd("Plug 'dracula/vim',{'as':'dracula'}") -- TODO: handle plugs with additional options in lua
Plug 'morhetz/gruvbox'
Plug 'ajh17/Spacegray.vim'
Plug 'junk-e/identity.vim'
Plug 'Mizux/vim-colorschemes'
Plug 'camgunz/amber'
Plug 'kyoto-shift/film-noir'
Plug 'pcostasgr/red_alert_vim_theme'
Plug 'abnt713/vim-hashpunk'
Plug 'TroyFletcher/vim-colors-synthwave'
Plug 'wadackel/vim-dogrun'
Plug 'joshdick/onedark.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'Rigellute/rigel'
Plug 'sainnhe/edge'
Plug 'cocopon/iceberg.vim'
Plug 'sainnhe/gruvbox-material'
Plug 'sickill/vim-monokai'

Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'scrooloose/nerdtree'

-- Git support
Plug 'jreybert/vimagit'
Plug 'airblade/vim-gitgutter'

-- fzf integration
vim.cmd("Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }") -- TODO: ditto
Plug 'junegunn/fzf.vim'

-- Adds :BufOnly to close all buffers except the current one
Plug 'schickling/vim-bufonly'

-- Makes <Leader>b display a listing of all buffers
Plug 'jeetsukumaran/vim-buffergator'

-- Comment/uncomment a line with 'gcc', or a selection with 'gc'
Plug 'tpope/vim-commentary'

-- Minimize visual noise with :Goyo and :Limelight
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

Plug 'tpope/vim-markdown'
Plug 'neui/cmakecache-syntax.vim'
Plug 'tpope/vim-surround'
Plug 'cespare/vim-toml'
Plug 'dag/vim-fish'

-- Have vim insert a matching 'end', 'endif', 'endfunction', etc.
Plug 'tpope/vim-endwise'

-- Perform autocompletion with just TAB
Plug 'ervandew/supertab'

-- Lightweight personal vim wiki
Plug 'vimwiki/vimwiki'

vim.call("plug#end")
