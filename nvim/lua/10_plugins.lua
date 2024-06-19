-- Logic for plugin managers goes here

-- Lua adapter for vim-plug
-- Adapted from https://www.reddit.com/r/neovim/comments/xvbhs2/how_to_use_vim_plug_with_initlua/
-- and some help from https://dev.to/vonheikemen/neovim-using-vim-plug-in-lua-3oom
local Plug = vim.fn["plug#"]
vim.call("plug#begin", vim.fn.stdpath("data") .. "/plugged")

-- Recommended LSP configs
Plug("neovim/nvim-lspconfig")
Plug("nvimtools/none-ls.nvim")

-- tabline & statusline
Plug("nvim-lualine/lualine.nvim")

-- Automatic completion for braces and other open/close characters
Plug("windwp/nvim-autopairs")
Plug("RRethy/nvim-treesitter-endwise")

-- Color schemes
Plug("dracula/vim", { as = "dracula" })
Plug("morhetz/gruvbox")
Plug("junk-e/identity.vim")
Plug("Mizux/vim-colorschemes")
Plug("camgunz/amber")
Plug("kyoto-shift/film-noir")
Plug("pcostasgr/red_alert_vim_theme")
Plug("abnt713/vim-hashpunk")
Plug("TroyFletcher/vim-colors-synthwave")
Plug("wadackel/vim-dogrun")
Plug("joshdick/onedark.vim")
Plug("arcticicestudio/nord-vim")
Plug("Rigellute/rigel")
Plug("sainnhe/edge")
Plug("cocopon/iceberg.vim")
Plug("sainnhe/gruvbox-material")
Plug("sickill/vim-monokai")
Plug("Mofiqul/vscode.nvim")

-- File browser
Plug("nvim-tree/nvim-tree.lua")
Plug("nvim-tree/nvim-web-devicons")

-- Git support
Plug("lewis6991/gitsigns.nvim")

-- Fuzzy finder
Plug("nvim-lua/plenary.nvim")
Plug("nvim-telescope/telescope.nvim")
Plug("nvim-telescope/telescope-symbols.nvim")
Plug("nvim-telescope/telescope-ui-select.nvim")
Plug("benfowler/telescope-luasnip.nvim")
Plug("rafamadriz/friendly-snippets")

-- Adds :BufOnly to close all buffers except the current one
Plug("schickling/vim-bufonly")

-- Minimize visual noise with :Goyo and :Limelight
Plug("junegunn/goyo.vim")
Plug("junegunn/limelight.vim")

Plug("tpope/vim-markdown")
Plug("neui/cmakecache-syntax.vim")
Plug("kylechui/nvim-surround")
Plug("cespare/vim-toml")
Plug("dag/vim-fish")
Plug("tpope/vim-fugitive")

-- Commenting support
Plug("numToStr/Comment.nvim")

-- Animate cursor jumps
Plug("danilamihailov/beacon.nvim")

-- Show vertical lines for each indent level
Plug("lukas-reineke/indent-blankline.nvim")

-- Underline the word under the cursor
Plug("yamatsum/nvim-cursorline")

-- nvim-treesitter for better syntax highlighting
Plug("nvim-treesitter/nvim-treesitter", {
	["do"] = function()
		vim.cmd("TSUpdate")
	end,
})
Plug("nvim-treesitter/nvim-treesitter-textobjects")

-- nvim-cmp plugins
Plug("hrsh7th/cmp-nvim-lsp")
Plug("hrsh7th/cmp-nvim-lua")
Plug("hrsh7th/cmp-buffer")
Plug("hrsh7th/cmp-path")
Plug("hrsh7th/cmp-cmdline")
Plug("hrsh7th/nvim-cmp")
Plug("hrsh7th/cmp-nvim-lsp-signature-help")
Plug("ray-x/cmp-treesitter")

-- Spellchecking for nvim-cmp
Plug("uga-rosa/cmp-dictionary")

-- LuaSnip, to support nvim-cmp
Plug("L3MON4D3/LuaSnip", { ["do"] = "make install_jsregexp" })
Plug("saadparwaiz1/cmp_luasnip")

-- Icons in completion menu
Plug("onsails/lspkind.nvim")

-- Better text copying in tmux and/or remote hosts
Plug("ojroques/nvim-osc52")

-- Highlight certain characters that can be navigated to with f|F|t|T motions
Plug("jinh0/eyeliner.nvim")

-- Show completions for command
Plug("folke/which-key.nvim")

-- Better navigation
Plug("tpope/vim-repeat")
Plug("ggandor/leap.nvim")

-- Show LSP progress
Plug("j-hui/fidget.nvim", { tag = "legacy" })

-- LSP quality of life enhancements
Plug("nvimdev/lspsaga.nvim")

-- DAP (debugging) setup
Plug("folke/neodev.nvim")
Plug("nvim-neotest/nvim-nio")
Plug("mfussenegger/nvim-dap")
Plug("rcarriga/nvim-dap-ui")
Plug("nvim-telescope/telescope-dap.nvim")
Plug("theHamsta/nvim-dap-virtual-text")
Plug("mfussenegger/nvim-dap-python")

-- overseer.nvim (task runner)
Plug("stevearc/dressing.nvim")
Plug("rcarriga/nvim-notify")
Plug("stevearc/overseer.nvim")

-- TODO: still not sold on this, saw some performance hitches on WSL...
-- undotree (view undo history)
-- Plug('mbbill/undotree')

-- Specialized Rust LSP setup
Plug("mrcjkb/rustaceanvim")

-- Retrieve JSON schemas for better LSP completion
Plug("b0o/schemastore.nvim")
Plug("someone-stole-my-name/yaml-companion.nvim")

-- AI plugins
Plug("MunifTanjim/nui.nvim")
Plug("folke/trouble.nvim")
Plug("jackmort/chatgpt.nvim")

vim.call("plug#end")
