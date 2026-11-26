-- which-key style popup for <leader> and `g` mappings when running inside VSCode.
--
-- which-key.nvim can't be used in VSCode, since vscode-neovim doesn't render nvim floating windows. Instead, the menu
-- is drawn by the "VSCode Which Key" extension (jellydn.vscode-whichkey, a maintained fork of VSpaceCode.whichkey),
-- whose `whichkey.show` command accepts a list of bindings as an argument. The bindings are generated on the fly from
-- nvim's own keymaps (so they're always in sync with config/vscode.lua, vscode-neovim's mappings, and any buffer-local
-- mappings), group names come from `KEY_GROUPS` in local/vars.lua (shared with which-key.nvim in the TUI), and
-- built-in `g` commands (which aren't keymaps) are listed from `G_DESCRIPTIONS` below.
--
-- How it behaves (mirrors classic which-key.nvim):
--  - Typing a full sequence quickly (within 'timeoutlen') runs it directly; no menu is shown.
--  - Pausing after a trigger key (<leader> or `g`), or after any partial sequence (e.g. <leader>d, gr), lets nvim's
--    'timeoutlen' expire, which triggers a mapping on that prefix that opens the menu scoped to it. N.B. the menu
--    therefore appears 'timeoutlen' ms after the last key, not immediately.
--  - If the key typed after a prefix doesn't continue any mapping (e.g. the second `g` of the built-in `gg`), nvim runs
--    the prefix mapping immediately with that key still pending. In that case the prefix is re-fed with noremap, so
--    nvim behaves exactly as if the menu mapping didn't exist (`gg`, `gj`, `gv`, `<Space>` + motion all work as usual).
--  - Picking an item sends the full key sequence back to nvim via `vscode-neovim.send`, so it's executed exactly as
--    if typed (operators like `<leader>a` or `gu` still wait for a motion, visual mode is preserved, etc.). Any count
--    or register given before the trigger (e.g. `5g`, `"+g`) is passed along too.
--
-- Why the trigger lives in nvim rather than in a VSCode keybinding: vscode-neovim reports operator-pending and other
-- half-typed states as "normal" mode, so a VSCode-side binding would hijack e.g. `f<Space>`, `r<Space>`, `dg`, `fg`.
-- nvim only fires the prefix mapping when the key actually starts a new command.
--
-- Limitations:
--  - Mappings containing special keys after the trigger (e.g. `<leader><M-.>`) are omitted, since they can't be typed
--    into the menu.
--  - If a mapping is also a prefix of longer mappings (e.g. `gc` and `gcc`), it's listed as a single item (`gc`); the
--    longer ones are still reachable by typing them. No menu mapping is created on such a prefix.

local vscode = require("vscode")

local M = {}

local MODES = { "n", "x" }

-- Keys which open the menu when followed by a pause
local function triggers()
  return { vim.g.mapleader or "\\", "g" }
end

-- `desc` given to the prefix mappings created here, so they can be excluded from the menu contents
local MENU_DESC = "which-key menu"

-- Descriptions for `g` commands, in the same spirit as which-key.nvim's presets (which the TUI uses). Used both to
-- list built-in commands that aren't keymaps, and as names for mappings without a `desc` (e.g. vscode-neovim's own).
-- Modes default to { "n" }.
local G_DESCRIPTIONS = {
  -- Built-ins
  { "g,",  "Newer position in change list" },
  { "g;",  "Older position in change list" },
  { "g?",  "Rot13 encode",                  { "n", "x" } },
  { "gE",  "Prev end of WORD",              { "n", "x" } },
  { "gI",  "Insert at column 1" },
  { "gJ",  "Join lines without spaces",     { "n", "x" } },
  { "gN",  "Search backwards and select",   { "n", "x" } },
  { "gP",  "Put before, leave cursor after" },
  { "gU",  "Uppercase",                     { "n", "x" } },
  { "g_",  "Last non-blank char",           { "n", "x" } },
  { "ge",  "Prev end of word",              { "n", "x" } },
  { "gg",  "First line",                    { "n", "x" } },
  { "gi",  "Go to last insert" },
  { "gn",  "Search forwards and select",    { "n", "x" } },
  { "gp",  "Put after, leave cursor after" },
  { "gu",  "Lowercase",                     { "n", "x" } },
  { "gv",  "Last visual selection" },
  { "gw",  "Format (keep cursor)",          { "n", "x" } },
  { "g~",  "Toggle case",                   { "n", "x" } },
  -- Mapped by vscode-neovim/plugins without a `desc`
  { "g$",  "End of screen line" },
  { "g%",  "Cycle backwards through results", { "n", "x" } },
  { "g0",  "Start of screen line" },
  { "gD",  "Peek definition",               { "n", "x" } },
  { "gF",  "Peek declaration",              { "n", "x" } },
  { "gH",  "Find references",               { "n", "x" } },
  { "gO",  "Document symbols",              { "n", "x" } },
  { "gT",  "Previous editor",               { "n", "x" } },
  { "gc",  "Comment",                       { "n", "x" } },
  { "gd",  "Go to definition",              { "n", "x" } },
  { "gf",  "Go to declaration",             { "n", "x" } },
  { "gh",  "Hover",                         { "n", "x" } },
  { "gj",  "Down (wrapped line)" },
  { "gk",  "Up (wrapped line)" },
  { "gq",  "Format",                        { "n", "x" } },
  { "gt",  "Next editor",                   { "n", "x" } },
}

-- { [lhs] = description } of the `G_DESCRIPTIONS` entries applicable to `mode`
local function g_descriptions(mode)
  local ret = {}
  for _, entry in ipairs(G_DESCRIPTIONS) do
    if vim.tbl_contains(entry[3] or { "n" }, mode) then
      ret[entry[1]] = entry[2]
    end
  end
  return ret
end

-- Split an lhs into keys: either a `<...>` keycode (e.g. `<C-a>`, `<lt>`) or a single (possibly multibyte) character
local function tokenize(lhs)
  local keys, i = {}, 1
  while i <= #lhs do
    local key = lhs:match("^<[^<>]+>", i) or lhs:match("^[%z\1-\127\194-\244][\128-\191]*", i)
    table.insert(keys, key)
    i = i + #key
  end
  return keys
end

local function is_special_key(key)
  return #key > 1 and key:sub(1, 1) == "<"
end

-- { [lhs] = group name } for `mode`, with `<leader>` expanded
local function group_names(mode)
  local names = {}
  for _, spec in ipairs(require("local.vars").KEY_GROUPS) do
    local modes = spec.mode or { "n" }
    modes = type(modes) == "string" and { modes } or modes
    -- "v" mappings apply to visual mode, i.e. "x"
    if vim.tbl_contains(modes, mode) or (mode == "x" and vim.tbl_contains(modes, "v")) then
      local lhs = spec[1]:gsub("<[lL]eader>", vim.g.mapleader or "\\")
      names[lhs] = spec.group
    end
  end
  return names
end

-- { [lhs] = keymap info } of all mappings under `prefix` active in `mode` for the current buffer
local function maps_under(mode, prefix)
  local maps = {}
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    maps[m.lhs] = m
  end
  -- Buffer-local mappings shadow global ones
  for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
    maps[m.lhs] = m
  end

  local ret = {}
  for lhs, m in pairs(maps) do
    if vim.startswith(lhs, prefix) and #lhs > #prefix and m.desc ~= MENU_DESC then
      ret[lhs] = m
    end
  end
  return ret
end

-- Count and/or register typed before the mapping that's currently executing (e.g. `5` or `"+`), so they can be passed
-- along to whatever ends up running
local function count_and_register()
  local keys = ""
  local clipboard = vim.o.clipboard
  local default_reg = clipboard:find("unnamedplus") and "+" or clipboard:find("unnamed") and "*" or '"'
  if vim.v.register ~= default_reg then
    keys = '"' .. vim.v.register
  end
  if vim.v.count > 0 then
    keys = keys .. vim.v.count
  end
  return keys
end

-- Convert a trie node's children into which-key extension binding items
local function to_bindings(node, names, keys_before)
  local items = {}
  for key, child in pairs(node.children) do
    if child.desc then
      -- A mapping (or built-in command) is listed as an item even if longer mappings extend it (e.g. `gc` vs `gcc`)
      table.insert(items, {
        key = key,
        name = child.desc,
        type = "command",
        command = "vscode-neovim.send",
        args = keys_before .. child.lhs,
      })
    else
      table.insert(items, {
        key = key,
        name = "+" .. (names[child.lhs] or "prefix"),
        type = "bindings",
        bindings = to_bindings(child, names, keys_before),
      })
    end
  end
  -- Same ordering as which-key.nvim's "alphanum" sort
  table.sort(items, function(a, b)
    local la, lb = a.key:lower(), b.key:lower()
    if la ~= lb then
      return la < lb
    end
    return a.key < b.key
  end)
  return items
end

-- Build the which-key binding items for everything under `prefix` in `mode`. `keys_before` (e.g. a count) is prepended
-- to each item's key sequence.
function M.bindings(mode, prefix, keys_before)
  local descriptions = g_descriptions(mode)

  -- { [lhs] = description } of everything to list
  local entries = {}
  for lhs, m in pairs(maps_under(mode, prefix)) do
    entries[lhs] = m.desc or descriptions[lhs] or m.rhs or lhs
  end
  for lhs, desc in pairs(descriptions) do
    if vim.startswith(lhs, prefix) and #lhs > #prefix and not entries[lhs] then
      entries[lhs] = desc
    end
  end

  local root = { children = {} }
  for lhs, desc in pairs(entries) do
    local keys = tokenize(lhs:sub(#prefix + 1))
    if not vim.iter(keys):any(is_special_key) then
      local node, path = root, prefix
      for _, key in ipairs(keys) do
        path = path .. key
        node.children[key] = node.children[key] or { children = {}, lhs = path }
        node = node.children[key]
      end
      node.desc = desc
    end
  end
  return to_bindings(root, group_names(mode), keys_before or "")
end

-- Show the which-key menu for everything under `prefix` in `mode`
function M.show(mode, prefix, keys_before)
  local bindings = M.bindings(mode, prefix, keys_before)
  if #bindings > 0 then
    vscode.action("whichkey.show", { args = { bindings } })
  end
end

-- Callback for the mapping on `prefix`
local function on_prefix(mode, prefix)
  local keys_before = count_and_register()
  if vim.fn.getchar(1) ~= 0 then
    -- A key is already pending, i.e. one that didn't continue any mapping under `prefix` (e.g. the second `g` of
    -- `gg`). Re-feed what was consumed without remapping, ahead of the pending key, so the built-in command runs.
    vim.api.nvim_feedkeys(keys_before .. vim.keycode(prefix), "ni", false)
    return
  end
  M.show(mode, prefix, keys_before)
end

-- Create a menu-opening mapping on each trigger key, and on every prefix under it that has mappings beneath it
local function install_prefix_maps()
  for _, mode in ipairs(MODES) do
    for _, trigger in ipairs(triggers()) do
      local prefixes = { [trigger] = true }
      for lhs in pairs(maps_under(mode, trigger)) do
        local keys = tokenize(lhs)
        local acc = ""
        for i = 1, #keys - 1 do
          acc = acc .. keys[i]
          if vim.startswith(acc, trigger) then
            prefixes[acc] = true
          end
        end
      end

      for prefix in pairs(prefixes) do
        -- Don't clobber a real mapping on the prefix
        if vim.fn.maparg(prefix, mode) == "" then
          vim.keymap.set(mode, prefix, function() on_prefix(mode, prefix) end, { desc = MENU_DESC })
        end
      end
    end
  end
end

function M.setup()
  -- Wait until startup is complete so that all mappings exist
  if vim.v.vim_did_enter == 1 then
    install_prefix_maps()
  else
    vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = install_prefix_maps })
  end
end

return M
