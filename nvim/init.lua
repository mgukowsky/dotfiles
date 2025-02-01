-- Before we do anything else, let's put logs in /tmp.
-- I don't need logs to be persistent, and I don't want to have
-- to monitor/manage an ever-expanding log file (esp. true
-- of LSP logs).
local NEW_TMP_PATH = "/tmp/nvim/logs"
vim.fn.mkdir(NEW_TMP_PATH, "p")

-- Per https://www.reddit.com/r/neovim/comments/s2t0ph/comment/hsgqrv6
local old_stdpath = vim.fn.stdpath
vim.fn.stdpath = function(value)
  if value == "log" then
    return NEW_TMP_PATH
  end
  return old_stdpath(value)
end

-- If false, fallback to using nvim-cmp
G_USE_BLINK = false

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
require("config.profiler")

-- Setup all plugins
lazy.setup_lazy()

vim.cmd.colorscheme("tokyonight-night")
