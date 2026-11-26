-- which-key style popup for <leader> and `g` mappings when running inside VSCode.
--
-- which-key.nvim can't be used in VSCode, since vscode-neovim doesn't render nvim floating windows. Instead, the menu
-- is drawn by the "VSCode Which Key" extension (jellydn.vscode-whichkey), whose `whichkey.show` command accepts a list
-- of bindings as an argument. The menu is generated on the fly from nvim's own keymaps (so it's always in sync with
-- config/vscode.lua, vscode-neovim's mappings, and buffer-local mappings), plus `G_DESCRIPTIONS` below for built-in
-- `g` commands (which aren't keymaps). Group names come from `KEY_GROUPS` in local/vars.lua, shared with which-key.nvim.
--
-- How it behaves (mirrors classic which-key.nvim):
--  - Typing a full sequence quickly (within 'timeoutlen') runs it directly; no menu is shown.
--  - Pausing after a trigger (<leader> or `g`) or a partial sequence (e.g. <leader>d, gr) lets 'timeoutlen' expire,
--    which fires a mapping on that prefix that opens the menu scoped to it.
--  - If the next key doesn't continue any mapping (e.g. the second `g` of the built-in `gg`), nvim fires the prefix
--    mapping immediately with that key pending; the prefix is then re-fed without remapping, so nvim behaves exactly
--    as if the menu mapping didn't exist.
--  - Picking an item sends its keys (preceded by any count/register, e.g. `5g`, `"+g`) back to nvim via
--    `vscode-neovim.send`, so it runs exactly as if typed (operators still wait for a motion, visual mode is kept).
--
-- The trigger lives in nvim rather than in a VSCode keybinding because vscode-neovim reports operator-pending and other
-- half-typed states as "normal" mode, so a VSCode-side binding would hijack e.g. `f<Space>`, `r<Space>`, `dgg`.
--
-- Limitations: mappings with special keys after the prefix (e.g. `<leader><M-.>`) can't be typed into the menu, so
-- they're omitted. A mapping that's also a prefix (e.g. `gc` vs `gcc`) is listed as a single item.

local vscode = require("vscode")

local M = {}

local LEADER = vim.g.mapleader or "\\"
local TRIGGERS = { LEADER, "g" }
local MODES = { "n", "x" }
-- `desc` of the mappings created here, so they can be told apart from real ones
local MENU_DESC = "which-key menu"
-- A single (possibly multibyte) UTF-8 character
local UTF8_CHAR = "[%z\1-\127\194-\244][\128-\191]*"

-- Descriptions for `g` commands, in which-key.nvim spec format. Used to list built-ins that aren't keymaps, and as
-- names for mappings without a `desc` (e.g. vscode-neovim's own). `mode` defaults to "n", as in which-key.nvim.
local NX = { "n", "x" }
local G_DESCRIPTIONS = {
  -- Built-ins (cf. which-key.nvim's presets)
  { "g,", desc = "Newer position in change list" },
  { "g;", desc = "Older position in change list" },
  { "g?", desc = "Rot13 encode",                    mode = NX },
  { "gE", desc = "Prev end of WORD",                mode = NX },
  { "gI", desc = "Insert at column 1" },
  { "gJ", desc = "Join lines without spaces",       mode = NX },
  { "gN", desc = "Search backwards and select",     mode = NX },
  { "gP", desc = "Put before, leave cursor after" },
  { "gU", desc = "Uppercase",                       mode = NX },
  { "g_", desc = "Last non-blank char",             mode = NX },
  { "ge", desc = "Prev end of word",                mode = NX },
  { "gg", desc = "First line",                      mode = NX },
  { "gi", desc = "Go to last insert" },
  { "gn", desc = "Search forwards and select",      mode = NX },
  { "gp", desc = "Put after, leave cursor after" },
  { "gu", desc = "Lowercase",                       mode = NX },
  { "gv", desc = "Last visual selection" },
  { "gw", desc = "Format (keep cursor)",            mode = NX },
  { "g~", desc = "Toggle case",                     mode = NX },
  -- Mapped by vscode-neovim/plugins without a `desc`
  { "g$", desc = "End of screen line" },
  { "g%", desc = "Cycle backwards through results", mode = NX },
  { "g0", desc = "Start of screen line" },
  { "gD", desc = "Peek definition",                 mode = NX },
  { "gF", desc = "Peek declaration",                mode = NX },
  { "gH", desc = "Find references",                 mode = NX },
  { "gO", desc = "Document symbols",                mode = NX },
  { "gT", desc = "Previous editor",                 mode = NX },
  { "gc", desc = "Comment",                         mode = NX },
  { "gd", desc = "Go to definition",                mode = NX },
  { "gf", desc = "Go to declaration",               mode = NX },
  { "gh", desc = "Hover",                           mode = NX },
  { "gj", desc = "Down (wrapped line)" },
  { "gk", desc = "Up (wrapped line)" },
  { "gq", desc = "Format",                          mode = NX },
  { "gt", desc = "Next editor",                     mode = NX },
}

-- { [lhs] = spec[field] } for the which-key.nvim style `specs` that apply to `mode` (where "v" also means "x")
local function lookup(specs, mode, field)
  local ret = {}
  for _, spec in ipairs(specs) do
    local modes = table.concat(type(spec.mode) == "table" and spec.mode or { spec.mode or "n" })
    if modes:find(mode, 1, true) or (mode == "x" and modes:find("v", 1, true)) then
      ret[(spec[1]:gsub("<[lL]eader>", LEADER))] = spec[field]
    end
  end
  return ret
end

-- Build a tree of everything under `prefix` in `mode`. Each node is `{ lhs, children, desc }`, where `desc` is only
-- set on nodes that are themselves a mapping or built-in command.
local function tree(mode, prefix)
  local descs = lookup(G_DESCRIPTIONS, mode, "desc")
  local entries = vim.deepcopy(descs) -- built-ins; real mappings override them below
  -- Buffer-local mappings come last so that they shadow global ones
  for _, m in ipairs(vim.list_extend(vim.api.nvim_get_keymap(mode), vim.api.nvim_buf_get_keymap(0, mode))) do
    if m.desc ~= MENU_DESC then
      entries[m.lhs] = m.desc or descs[m.lhs] or m.rhs or m.lhs
    end
  end

  local root = { lhs = prefix, children = {} }
  for lhs, desc in pairs(entries) do
    local suffix = lhs:sub(#prefix + 1)
    if vim.startswith(lhs, prefix) and suffix ~= "" and not suffix:find("<", 1, true) then
      local node = root
      for key in suffix:gmatch(UTF8_CHAR) do
        node.children[key] = node.children[key] or { lhs = node.lhs .. key, children = {} }
        node = node.children[key]
      end
      node.desc = desc
    end
  end
  return root
end

-- Convert a tree node's children into which-key extension binding items, prefixing each item's keys with `keys_before`
local function to_bindings(node, group_names, keys_before)
  local items = {}
  for key, child in pairs(node.children) do
    table.insert(items, child.desc and {
      key = key,
      name = child.desc,
      type = "command",
      command = "vscode-neovim.send",
      args = keys_before .. child.lhs,
    } or {
      key = key,
      name = "+" .. (group_names[child.lhs] or "prefix"),
      type = "bindings",
      bindings = to_bindings(child, group_names, keys_before),
    })
  end
  -- Same order as which-key.nvim's "alphanum" sort: case-insensitive, then uppercase first
  table.sort(items, function(a, b) return a.key:lower() .. a.key < b.key:lower() .. b.key end)
  return items
end

-- Count and/or register typed before the currently executing mapping (e.g. `5` or `"+`), so they can be passed along
local function count_and_register()
  local clipboard = vim.o.clipboard
  local default_reg = clipboard:find("unnamedplus") and "+" or clipboard:find("unnamed") and "*" or '"'
  return (vim.v.register ~= default_reg and '"' .. vim.v.register or "")
      .. (vim.v.count > 0 and vim.v.count or "")
end

-- Callback for the menu mapping on `prefix`
local function on_prefix(mode, prefix)
  local keys_before = count_and_register()
  if vim.fn.getchar(1) ~= 0 then
    -- A key that doesn't continue any mapping is pending (e.g. the second `g` of `gg`): re-feed what was consumed
    -- without remapping, ahead of that key, so the built-in command runs
    vim.api.nvim_feedkeys(keys_before .. vim.keycode(prefix), "ni", false)
    return
  end
  local items = to_bindings(tree(mode, prefix), lookup(require("local.vars").KEY_GROUPS, mode, "group"), keys_before)
  if #items > 0 then
    vscode.action("whichkey.show", { args = { items } })
  end
end

-- Create a menu mapping on each trigger, and on each prefix beneath it that isn't itself mapped (e.g. <leader>d, gr)
local function install_menu_maps()
  for _, mode in ipairs(MODES) do
    local function walk(node)
      if vim.fn.maparg(node.lhs, mode) == "" then
        vim.keymap.set(mode, node.lhs, function() on_prefix(mode, node.lhs) end, { desc = MENU_DESC })
      end
      for _, child in pairs(node.children) do
        if next(child.children) then
          walk(child)
        end
      end
    end
    for _, trigger in ipairs(TRIGGERS) do
      walk(tree(mode, trigger))
    end
  end
end

function M.setup()
  -- Wait until startup is complete so that all mappings exist
  if vim.v.vim_did_enter == 1 then
    install_menu_maps()
  else
    vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = install_menu_maps })
  end
end

return M
