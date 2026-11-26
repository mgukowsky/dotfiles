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

G_COLORSCHEME = "tokyonight-night"

-- If false, fallback to using nvim-cmp
G_USE_BLINK = false

-- True when nvim is embedded in VSCode via the vscode-neovim extension, which sets `g:vscode` before this file runs.
-- In this mode VSCode owns the UI, insert mode, LSP, etc., so only text-editing plugins are loaded
-- (see `defaults.cond` in config/lazy.lua) and many mappings are redirected to VSCode commands (see config/vscode.lua).
G_IS_VSCODE = vim.g.vscode ~= nil

local lazy = require("config.lazy")
lazy.bootstrap_lazy()

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
require("config.opts")
if G_IS_VSCODE then
  require("config.vscode")
else
  require("config.mappings")
end
require("config.autocommands")
require("config.profiler")

-- Setup all plugins
lazy.setup_lazy()

-- Everything below is only relevant to the TUI
if G_IS_VSCODE then
  return
end

-- nvim opt-in plugins (https://neovim.io/doc/user/plugins/)
vim.cmd.packadd("nvim.tohtml")
vim.cmd.packadd("nvim.undotree")

-- Enable next-gen UI
require("vim._core.ui2").enable()

vim.cmd.colorscheme(G_COLORSCHEME)
