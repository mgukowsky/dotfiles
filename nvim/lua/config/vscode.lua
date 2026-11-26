-- Mappings for when nvim is embedded in VSCode via vscode-neovim (https://github.com/vscode-neovim/vscode-neovim).
-- Loaded instead of config/mappings.lua when G_IS_VSCODE is set.
--
-- Plugins that only make sense in the TUI (pickers, file trees, terminals, LSP/DAP clients, UI chrome, etc.) are not
-- loaded in VSCode (see `defaults.cond` in config/lazy.lua). Where such a plugin provides functionality that VSCode has
-- natively, its mappings are recreated here, pointing at the equivalent VSCode command.
--
-- Things vscode-neovim already handles for us, and which are therefore NOT mapped here:
--  - `gc`/`gcc` (commenting; replaces Comment.nvim's linewise mappings), `gq`/`=` (formatting)
--  - `K`/`gh` (hover), `gd`, `gD`, `gf`, `gF`, `gH`, `gO` (document symbols)
--  - `<C-w>` window navigation (replaces the hydra.nvim "Window nav" head)
--  - `vim.lsp.buf.*` is shimmed to VSCode commands, so nvim's default `grn` (rename), `gra` (code action) and `grt`
--    (type definition) mappings work as-is
--  - F5/F9/F10/F11/Shift+F11 are never sent to nvim; VSCode's native debug bindings already match the nvim-dap ones
--  - <C-p> is not forwarded to nvim by default, so VSCode's native Quick Open handles it (it's mapped below anyway, in
--    case `vscode-neovim.ctrlKeysForNormalMode` is ever changed to forward it)
--
-- N.B. Ctrl-key mappings only reach nvim if the key is listed in `vscode-neovim.ctrlKeysForNormalMode`; see
-- vscode/settings.json in the dotfiles repo (<C-n> and <C-q> are added there).

local vscode = require("vscode")

-- Returns a function which invokes the given VSCode command asynchronously
local function action(cmd, opts)
  return function()
    vscode.action(cmd, opts)
  end
end

-- Batch-define mappings, with the same `{ lhs, rhs, desc = ..., mode = ... }` shape as lazy.nvim `keys` specs.
-- A string rhs is treated as a VSCode command ID.
local function map_all(specs)
  for _, spec in ipairs(specs) do
    local rhs = spec[2]
    if type(rhs) == "string" then
      rhs = action(rhs)
    end
    vim.keymap.set(spec.mode or "n", spec[1], rhs, { desc = spec.desc, expr = spec.expr })
  end
end

-- Leave visual mode after an operator acts on a selection (mirrors vscode-neovim's own gc/gq implementation)
local function esc()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, true, true), "n", false)
end

-- Open VSCode's search panel (the Telescope grep equivalent) with the text covered by a motion
local text_operator = require("local.util").text_operator
local function find_in_files_op(is_regex)
  return text_operator(function(text)
    vscode.action("workbench.action.findInFiles", {
      args = { query = text, isRegex = is_regex, triggerSearch = true },
    })
  end)
end

-- Comment.nvim's blockwise `gb` operator; VSCode's block comment toggle wraps the range in e.g. /* */
local block_comment_op = vscode.to_op(function(ctx)
  vscode.action("editor.action.blockComment", { range = ctx.range, callback = esc })
end)

map_all({
  ---------------------------------------------------------------------------------------------------------------------
  -- config/mappings.lua
  ---------------------------------------------------------------------------------------------------------------------
  { "<C-h>",   "workbench.action.previousEditor",    desc = "Previous buffer" },
  { "<C-l>",   "workbench.action.nextEditor",        desc = "Next buffer" },
  -- Arrows resize splits (VSCode editor groups)
  { "<Up>",    "workbench.action.decreaseViewHeight", desc = "Resize horizontal up" },
  { "<Down>",  "workbench.action.increaseViewHeight", desc = "Resize horizontal down" },
  { "<Left>",  "workbench.action.decreaseViewWidth",  desc = "Resize vertical left" },
  { "<Right>", "workbench.action.increaseViewWidth",  desc = "Resize vertical right" },

  ---------------------------------------------------------------------------------------------------------------------
  -- Comment.nvim (blockwise; linewise `gc` is provided by vscode-neovim)
  ---------------------------------------------------------------------------------------------------------------------
  { "gb",  block_comment_op,                                   desc = "Block comment",      expr = true, mode = { "n", "x" } },
  { "gbc", function() return block_comment_op() .. "_" end,    desc = "Block comment line", expr = true },

  ---------------------------------------------------------------------------------------------------------------------
  -- telescope.nvim
  ---------------------------------------------------------------------------------------------------------------------
  { "<C-p>",            "workbench.action.quickOpen",                       desc = "Find files" },
  { "<leader>a",        find_in_files_op(false),                            desc = "Grep motion",      expr = true, mode = { "n", "x" } },
  { "<leader>b",        "workbench.action.showAllEditorsByMostRecentlyUsed", desc = "Show buffers" },
  { "<leader>p",        "workbench.action.showCommands",                    desc = "Command search" },
  { "<leader>s",        "editor.action.insertSnippet",                      desc = "Snippet search" },
  { "<leader>w",        find_in_files_op(true),                             desc = "Live grep motion", expr = true, mode = { "n", "x" } },
  -- The `?` prefix lists every Quick Open provider, i.e. VSCode's "picker of pickers"
  { "<leader><leader>", action("workbench.action.quickOpen", { args = { "?" } }), desc = "Picker search" },

  ---------------------------------------------------------------------------------------------------------------------
  -- LSP (lsp.lua on_attach; lspsaga)
  ---------------------------------------------------------------------------------------------------------------------
  -- vscode-neovim maps <C-]> to go-to-definition; the TUI config uses peek
  { "<C-]>",      "editor.action.peekDefinition",           desc = "Peek definition" },
  -- VSCode's editor context menu is the equivalent of the custom ]LSPMenu popup
  { "<leader>]",  "editor.action.showContextMenu",          desc = "LSP Popup menu" },
  { "<leader>n",  "outline.focus",                          desc = "LSP code outline" },
  { "<leader>la", "editor.action.quickFix",                 desc = "LSP code action" },
  { "<leader>ld", "workbench.actions.view.problems",        desc = "Diagnostics" },
  {
    "<leader>li",
    function()
      -- There's no toggle command for inlay hints, so flip the setting. N.B. this persists to user settings.json.
      local setting = "editor.inlayHints.enabled"
      local new_value = vscode.get_config(setting) == "off" and "on" or "off"
      vscode.update_config(setting, new_value, "global")
    end,
    desc = "Toggle Inlay Hints",
  },
  { "<leader>ls", "workbench.action.gotoSymbol",            desc = "Document Symbol search" },
  { "<leader>lw", "workbench.action.showAllSymbols",        desc = "Workspace Symbol search" },

  ---------------------------------------------------------------------------------------------------------------------
  -- trouble.nvim; the References view and Problems panel are VSCode's equivalents of Trouble's list windows
  ---------------------------------------------------------------------------------------------------------------------
  { "<C-q>", "workbench.action.togglePanel",              desc = "Toggle panel" },
  { "grc",   "editor.showIncomingCalls",                  desc = "Incoming Calls" },
  { "grd",   "workbench.actions.view.problems",           desc = "Diagnostics" },
  { "gri",   "references-view.findImplementations",       desc = "Implementations" },
  { "gro",   "editor.showOutgoingCalls",                  desc = "Outgoing Calls" },
  { "grr",   "references-view.findReferences",            desc = "References" },
  { "grs",   "outline.focus",                             desc = "Symbols" },
  -- Grep results go to the quickfix list in the TUI; in VSCode they go to the search panel
  { "[q",    "search.action.focusPreviousSearchResult",   desc = "Previous search result" },
  { "]q",    "search.action.focusNextSearchResult",       desc = "Next search result" },

  ---------------------------------------------------------------------------------------------------------------------
  -- gitsigns.nvim (VSCode's SCM "dirty diff" gutter is the gitsigns equivalent)
  ---------------------------------------------------------------------------------------------------------------------
  { "]c",         "workbench.action.editor.nextChange",     desc = "Next Git change" },
  { "[c",         "workbench.action.editor.previousChange", desc = "Prev Git change" },
  { "<leader>hb", "git.blame.toggleEditorDecoration",       desc = "Toggle inline blame" },
  { "<leader>hD", "git.openChange",                         desc = "Diff current file" },
  { "<leader>hp", "editor.action.dirtydiff.next",           desc = "Preview hunk" },
  { "<leader>hr", "git.unstage",                            desc = "Undo stage buffer" },
  { "<leader>hR", "git.clean",                              desc = "Reset buffer" },
  -- The "selected range" in normal mode is the cursor line, i.e. the hunk under the cursor
  { "<leader>hs", "git.stageSelectedRanges",                desc = "Stage hunk" },
  { "<leader>hS", "git.stage",                              desc = "Stage buffer" },
  { "<leader>hu", "git.revertSelectedRanges",               desc = "Reset hunk" },

  ---------------------------------------------------------------------------------------------------------------------
  -- nvim-tree.lua, toggleterm.nvim, overseer.nvim
  ---------------------------------------------------------------------------------------------------------------------
  { "<C-n>",      "workbench.view.explorer",                desc = "File explorer" },
  { "<leader>`",  "workbench.action.terminal.toggleTerminal", desc = "Toggle terminal" },
  { "<leader>~",  "workbench.action.quickOpenTerm",         desc = "Select terminal" },
  { "<leader>oc", "workbench.action.closePanel",            desc = "Close" },
  { "<leader>oo", "workbench.action.tasks.showTasks",       desc = "Open" },
  { "<leader>or", "workbench.action.tasks.runTask",         desc = "Run" },
  { "<leader>ot", "workbench.action.togglePanel",           desc = "Toggle" },

  ---------------------------------------------------------------------------------------------------------------------
  -- nvim-dap
  ---------------------------------------------------------------------------------------------------------------------
  { "<leader>dbb", "editor.debug.action.toggleBreakpoint",  desc = "Toggle breakpoint" },
  { "<leader>dbc", "editor.debug.action.conditionalBreakpoint", desc = "Conditional breakpoint" },
  -- VSCode's conditional breakpoint widget has a dropdown to switch to a hit count condition
  { "<leader>dbh", "editor.debug.action.conditionalBreakpoint", desc = "Hit conditional breakpoint" },
  { "<leader>dbl", "editor.debug.action.addLogPoint",       desc = "Set breakpoint with log message" },
  {
    "<leader>dc",
    function()
      -- Like dap.continue(): start a session if there isn't one, otherwise continue
      vscode.eval_async([[
        const cmd = vscode.debug.activeDebugSession ? "workbench.action.debug.continue" : "workbench.action.debug.start";
        await vscode.commands.executeCommand(cmd);
      ]])
    end,
    desc = "Start/Continue execution",
  },
  { "<leader>dfc", "workbench.action.debug.callStackTop",   desc = "Go to current (active) frame" },
  { "<leader>dff", "workbench.action.debug.callStackTop",   desc = "Go to current (active) frame" },
  { "<leader>dfd", "workbench.action.debug.callStackDown",  desc = "Go down one frame" },
  { "<leader>dfr", "workbench.action.debug.restartFrame",   desc = "Restart execution of the current frame" },
  { "<leader>dfu", "workbench.action.debug.callStackUp",    desc = "Go up one frame" },
  { "<leader>dK",  "editor.debug.action.showDebugHover",    desc = "Evaluate expression under cursor" },
  { "<leader>dn",  "workbench.action.debug.stepOver",       desc = "Step Over" },
  { "<leader>do",  "workbench.action.debug.stepOut",        desc = "Step Out" },
  { "<leader>dp",  "workbench.action.debug.pause",          desc = "Pause execution" },
  { "<leader>ds",  "workbench.action.debug.stepInto",       desc = "Step Into" },
  { "<leader>dt",  "workbench.view.debug",                  desc = "Show debug view" },
  { "<leader>du",  "editor.debug.action.runToCursor",       desc = "Run until current line" },
  { "<leader>dw",  "editor.debug.action.selectionToWatch",  desc = "Watch the current expression" },
  { "<leader>dx",  "workbench.action.debug.stop",           desc = "Terminate running program" },
  { "<leader>dqq", action("workbench.action.quickOpen", { args = { ">Debug: " } }), desc = "Command search" },
  { "<leader>dqb", "workbench.debug.action.focusBreakpointsView", desc = "List breakpoints" },
  { "<leader>dqc", "workbench.action.debug.selectandstart", desc = "Select configuration" },
  { "<leader>dqf", "workbench.debug.action.focusCallStackView", desc = "List frames" },
  { "<leader>dqv", "workbench.debug.action.focusVariablesView", desc = "List variables" },
})

-- which-key style menu for <leader> and `g` mappings (requires the jellydn.vscode-whichkey extension)
require("local.vscode_whichkey").setup()
