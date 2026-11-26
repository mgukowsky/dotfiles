local M = {}

M.TS_PARSERS = {
  "asm",
  "bash",
  "c",
  "cmake",
  "comment",
  "cpp",
  "glsl",
  "html",
  "javascript",
  "json",
  "latex",
  "lua",
  "markdown",
  "markdown_inline",
  "mermaid",
  "nasm",
  "python",
  "ruby",
  "rust",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
}

-- Names for groups of mappings, in which-key.nvim spec format. Shared by which-key.nvim in the TUI and by the
-- which-key menu in VSCode (see config/vscode.lua). Group descriptions for mappings given as "keys" args in a lazy
-- spec need to be defined here.
M.KEY_GROUPS = {
  { "gr",         mode = { "n", "v" }, group = "LSP Actions" }, -- nvim builtins
  { "<leader>c",  mode = { "n", "v" }, group = "AI Agent" },
  { "<leader>d",  group = "Debugger (DAP)" },
  { "<leader>db", group = "Breakpoints" },
  { "<leader>df", group = "Frames" },
  { "<leader>dq", group = "DAP commands" },
  { "<leader>h",  group = "Git Hunk operations" },
  { "<leader>l",  group = "LSP functions" },
  { "<leader>o",  group = "Overseer runner (tasks.json)" },
  { "<leader>q",  group = "Extended functionality" },
}

return M
