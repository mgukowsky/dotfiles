-- Logic for plugin managers goes here

-- Lua adapter for vim-plug
-- Adapted from https://www.reddit.com/r/neovim/comments/xvbhs2/how_to_use_vim_plug_with_initlua/
-- and some help from https://dev.to/vonheikemen/neovim-using-vim-plug-in-lua-3oom
local Plug = vim.fn["plug#"]
vim.call("plug#begin", vim.fn.stdpath("data") .. "/plugged")

-- Recommended LSP configs
Plug('neovim/nvim-lspconfig')

-- Vim-airline
Plug('vim-airline/vim-airline')
Plug('vim-airline/vim-airline-themes')

-- Automatic completion for braces and other open/close characters
Plug('townk/vim-autoclose')
Plug('ryanoasis/vim-devicons')

-- Color schemes
Plug('dracula/vim', { as = 'dracula' })
Plug('morhetz/gruvbox')
Plug('junk-e/identity.vim')
Plug('Mizux/vim-colorschemes')
Plug('camgunz/amber')
Plug('kyoto-shift/film-noir')
Plug('pcostasgr/red_alert_vim_theme')
Plug('abnt713/vim-hashpunk')
Plug('TroyFletcher/vim-colors-synthwave')
Plug('wadackel/vim-dogrun')
Plug('joshdick/onedark.vim')
Plug('arcticicestudio/nord-vim')
Plug('Rigellute/rigel')
Plug('sainnhe/edge')
Plug('cocopon/iceberg.vim')
Plug('sainnhe/gruvbox-material')
Plug('sickill/vim-monokai')
Plug('Mofiqul/vscode.nvim')

Plug('scrooloose/nerdtree')

-- Git support
Plug('lewis6991/gitsigns.nvim')

-- fzf integration; `[]` syntax is needed for `do`, since it's a reserved keyword
Plug('junegunn/fzf', { ['do'] = function() vim.call('fzf#install') end })
Plug('junegunn/fzf.vim')

-- Adds :BufOnly to close all buffers except the current one
Plug('schickling/vim-bufonly')

-- Makes <Leader>b display a listing of all buffers
Plug('jeetsukumaran/vim-buffergator')

-- Comment/uncomment a line with 'gcc', or a selection with 'gc'
Plug('tpope/vim-commentary')

-- Minimize visual noise with :Goyo and :Limelight
Plug('junegunn/goyo.vim')
Plug('junegunn/limelight.vim')

Plug('tpope/vim-markdown')
Plug('neui/cmakecache-syntax.vim')
Plug('tpope/vim-surround')
Plug('cespare/vim-toml')
Plug('dag/vim-fish')

-- Have vim insert a matching 'end', 'endif', 'endfunction', etc.
Plug('tpope/vim-endwise')

-- Animate cursor jumps
Plug('danilamihailov/beacon.nvim')

-- Show vertical lines for each indent level
Plug('Yggdroot/indentLine')

-- Underline the word under the cursor
Plug('yamatsum/nvim-cursorline')

-- nvim-treesitter for better syntax highlighting
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = function() vim.cmd('TSUpdate') end })

-- nvim-cmp plugins
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-nvim-lsp-signature-help')

-- LuaSnip, to support nvim-cmp
Plug('L3MON4D3/LuaSnip')
Plug('saadparwaiz1/cmp_luasnip')

-- Icons in completion menu
Plug('onsails/lspkind.nvim')

vim.call("plug#end")
