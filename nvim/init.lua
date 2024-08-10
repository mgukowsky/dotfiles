local lazy = require("config.lazy")
lazy.bootstrap_lazy()

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"
require("config.opts")
require("config.mappings")
require("config.autocommands")

-- Setup all plugins
lazy.setup_lazy()

vim.cmd.colorscheme("vscode")
