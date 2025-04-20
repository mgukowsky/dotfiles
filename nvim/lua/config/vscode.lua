-- Only use a minimal set of plugins if running within VSCode
-- Largely taken from how LazyVim approaches this:
-- https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/extras/vscode.lua

local vscode = require('vscode')

vim.notify = vscode.notify

local enabled = {
  "Comment.nvim",
  "eyeliner.nvim",
  --"gitsigns.nvim",
  "lazy.nvim",
  "leap.nvim",
  "nvim-autopairs",
  "nvim-surround",
  "nvim-treesitter",
  "nvim-treesitter-endwise",
  "nvim-treesitter-textobjects",
}

local Config                    = require("lazy.core.config")
Config.options.checker          = { enabled = false }
Config.options.change_detection = { enabled = false }
Config.options.defaults = {
  cond = function(plugin)
    return vim.list_contains(enabled, plugin.name) or plugin.vscode
  end
}

-- Mappings
local map = vim.keymap.set
map("n", "<C-h>", function() vscode.call("workbench.action.previousEditor") end, { desc = "Previous buffer" })
map("n", "<C-l>", function() vscode.call("workbench.action.nextEditor")end,  { desc = "Next buffer" })
map("n", "<C-n>", function() vscode.call("workbench.action.toggleSidebarVisibility")end,  { desc = "Toggle sidebar" })
map("n", "<leader>i", function() vscode.call("inlineChat.start")end,  { desc = "Next buffer" })
