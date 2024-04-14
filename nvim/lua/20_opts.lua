-- Various settings are managed here

-- Corresponds to the `:set` command
local opt = vim.opt

opt.autoindent = true -- Preserve previous line's indentation when staring a new line
opt.background = "dark"
opt.cindent = false   -- Don't use C indentation rules

--[[
-- Makes y and p commands use the global copy/paste buffer.
--
-- N.B. this probably won't play well with vim sessions over SSH. To copy in
-- such scenarios, either X11 forward hold SHIFT while click-dragging the mouse
-- to select and then copy-paste (can also enter `:set nonumber` to remove line
-- numbers first)
--]]
opt.clipboard:append("unnamedplus")

opt.completeopt = { 'menu', 'menuone', 'noselect' } -- Trigger menu for a single entry

opt.colorcolumn = { 100 }                           -- Rulers
opt.cursorline = true                               -- Highlight the current line as needed
opt.expandtab = true                                -- Use spaces instead of tabs
opt.exrc = true                                     -- Load external rc files, if present
opt.hidden = true                                   -- Remove warnings when switching btwn buffers that haven't yet been written out
opt.hlsearch = true                                 -- Highlight search match
opt.incsearch = true                                -- Match search as you type
opt.jumpoptions = "stack"                           -- Make jumplist function like a browser forward/back button

-- Characters used to represent whitespace
-- N.B. use the command `:set list` or `vim.opt.list = true` to see these
opt.list = false -- Don't show these whitespace characters
opt.listchars = { tab = ">-", space = "·", trail = "○", eol = "↲", nbsp = "▯" }

opt.mouse = "a"       -- Mouse support
opt.number = true     -- Show line numbers
opt.path:append("**") -- Better searching and tab completion for files

-- Commenting this out as it appears to screw with certain popups like the LSP menu
--opt.pumblend = 15         -- Transparent menus

-- Useful for quickly navigating up and down (e.g. 10j to go to the 10th line down), but somewhat
-- redundant with leap.nvim
-- opt.relativenumber = true -- Show line numbers relative to the current line number (useful for quick vertical navigation, e.g. 5j)
opt.scrolloff = 4        -- Min # of lines to keep around the cursor
opt.secure = true        -- Don't allow untrusted scripts to execute
opt.signcolumn = "yes:1" -- Always show the sign column and set the width to 1 character
opt.shiftwidth = 2       -- tab config
opt.showcmd = true       -- Show previous command
opt.showmatch = true
opt.smartindent = false
opt.softtabstop = 2      -- # of tab spaces in insert mode
opt.tabstop = 2          -- # of tab spaces
opt.termguicolors = true -- Use UI colors if supported

-- Set the timeout for keycode delays (i.e. for quick ESC responses)
-- See https://www.johnhawthorn.com/2012/09/vi-escape-delays/
opt.timeoutlen = 1000
opt.ttimeoutlen = 10

opt.title = true      -- Set the title of the window to the file being edited
opt.updatetime = 1000 -- Update buffers every second
opt.wrap = true       -- Wrap text
opt.wildmenu = true   -- Better searching and tab completion for files

-- A few options are managed through global variables
local g = vim.g -- Corresponds to "g:" variables
g.t_co = 256    -- Corresponds to vim's `t_Co`
g.base16colorspace = 256

-- Configuration for plugins; mainly managed through global variables

-- Make limelight OK with our transparent background
g.limelight_conceal_ctermfg = "DarkGray"
g.limelight_conceal_guifg = "DarkGray"

-- Prevent vim-markdown from hiding characters
g.markdown_syntax_conceal = 0

-- Show quote characters in JSON files
g.vim_json_conceal = 0

-- which-key.nvim
-- Shows completions for a command as characters are entered
-- (after vim.o.timeoutlen); can also be manually invoked with
-- :WhichKey <partial command...>
-- Also adds hooks in normal mode: will show marks when ` is pressed, and
-- registers when " is pressed, and will also show a menu for spelling suggestions
-- when z= is pressed
require("which-key").setup()

-- gitsigns.nvim (replaces GitGutter)
require('gitsigns').setup({
  numhl = true,
  -- Install recommended keybindings per https://github.com/lewis6991/gitsigns.nvim
  -- Very similar to what was in GitGutter
  on_attach = function(bufnr)
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
})

-- nvim-cursorline
require('nvim-cursorline').setup({
  cursorline = {
    enable = false
  },
  cursorword = {
    enable = true,
    min_length = 3,
    hl = { underline = true },
  }
})

--- nvim-treesitter
require("nvim-treesitter.configs").setup({
  ensure_installed = { "bash", "c", "cmake", "comment", "cpp", "javascript", "json", "lua",
    "markdown", "markdown_inline", "python", "ruby", "typescript", "vim", "vimdoc" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = { query = "@function.outer", desc = "Select an entire function" },
        ["if"] = { query = "@function.inner", desc = "Select a function body" },
        ["ac"] = { query = "@class.outer", desc = "Select an entire class" },
        ["ic"] = { query = "@class.inner", desc = "Select the body of a class" },
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select the current scope" },
      },
      include_surrounding_whitespace = false,
    },
  },
})

-- nvim-cmp configuration; from https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require('lspkind')
cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      menu = ({
        buffer = "🔠",
        nvim_lsp = "🐲",
        nvim_lua = "📜",
        luasnip = "🤓",
        dictionary = "📕",
        treesitter = "🎄"
      })
    }),
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.abort(),
    -- Supertab-like config, from the nvim-cmp wiki
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    -- Make <CR> complete the entry if one is selected, otherwise make a newline like normal;
    -- also from the nvim-cmp wiki
    ["<CR>"] = cmp.mapping({
      i = function(fallback)
        if cmp.visible() and cmp.get_active_entry() then
          cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
        else
          fallback()
        end
      end,
      s = cmp.mapping.confirm({ select = true }),
      -- This mapping seems to break <CR> functionality in other menus, such as the LSPMenu I
      -- create in 50_lsp.lua. Setting this to a function with a fallback doesn't seem to help...
      -- c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
    }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp',               keyword_length = 1 },
    { name = 'treesitter',             keyword_length = 2 },
    { name = 'nvim_lua',               keyword_length = 2 },
    { name = 'buffer',                 keyword_length = 2 },
    { name = 'luasnip',                keyword_length = 3 },
    { name = 'dictionary',             keyword_length = 6 },
    { name = 'nvim_lsp_signature_help' },
  })
})
-- Use buffer for completing "/" and "?" searches
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})
-- Use path and cmdline for completing ":" commands
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    -- Setting keyword_length to a low value can lead to performance issues, since it will try
    -- to match against _all_ possible commands. Observed that `:r!` caused nvim to lock up as
    -- nvim-cmp tried to match it against all possible commands on the system.
    { name = 'cmdline', keyword_length = 4 }
  })
})

local dict = require("cmp_dictionary")

dict.setup({})

local DICTFILEPATH = vim.fn.stdpath("data") .. "/en.dict"

-- Create the dictionary if it doesn't exist
-- Beware Lua falsy value rules (only `false` and `nil` are falsy 🙃)
if vim.fn.filereadable(DICTFILEPATH) == 0 and vim.fn.executable("aspell") == 1 then
  print("Creating dictionary file '" .. DICTFILEPATH .. "' with aspell")
  os.execute("aspell -d en dump master | aspell -l en expand > " .. DICTFILEPATH)
end

-- dict.switcher({
--   -- N.B. that given my locale, vim.opt.spelllang defaults to "en"
--   spelllang = {
--     en = DICTFILEPATH
--   }
-- })

-- nvim-tree.lua
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
require("nvim-tree").setup({
  disable_netrw = true,
  filters = {
    dotfiles = false,
  },
  view = {
    float = {
      enable = true
    }
  }
})
require("nvim-web-devicons").setup();

-- telescope.nvim

-- Make telescope search hidden directories and files, but not .git/
-- From https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#pickers
local telescope = require("telescope")
local telescopeConfig = require("telescope.config")
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

local HIDDEN = "--hidden"
local GLOB = "--glob"
local GIT_DIR_REGEX = "!**/.git/*"

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, HIDDEN)
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, GLOB)
table.insert(vimgrep_arguments, GIT_DIR_REGEX)

telescope.setup({
  defaults = {
    vimgrep_arguments = vimgrep_arguments,
    mappings = {
      i = {
        ["<esc>"] = "close", -- Close the popup instead of first going to normal mode
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      }
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown()
    }
  },
  pickers = {
    find_files = {
      find_command = { "rg", "--files", HIDDEN, GLOB, GIT_DIR_REGEX },
    }
  }
})
telescope.load_extension("dap")
telescope.load_extension("luasnip")
telescope.load_extension("ui-select")

-- nvim-osc52
require('osc52').setup({})

-- eyeliner.nvim
require('eyeliner').setup({
  highlight_on_key = true, -- Only highlight characters after pressing f|F|t|T
  dim = true,              -- Dim all charcters that can't be jumped to
})

-- Comment.nvim
require("Comment").setup()

-- nvim-surround
require("nvim-surround").setup()

-- indent-blankline.nvim
require("ibl").setup({
  indent = {
    char = "¦",
  },
  scope = {
    enabled = false,
  },
})

-- fidget.nvim
require("fidget").setup();

-- lspsaga.nvim
require("lspsaga").setup({
  callhierarchy = {
    keys = {
      edit = "<CR>",
      toggle_or_req = "<Space>",
    },
  },
  code_action = {
    extend_gitsigns = true,
    num_shortcut = true,
    show_server_name = true,
  },
  definition = {
    width = 0.8,
    height = 0.5,
    keys = {
      edit = "<CR>",
    },
  },
  diagnostic = {
    extend_relatedInformation = true,
  },
  finder = {
    keys = {
      toggle_or_open = "<CR>",
    },
    max_height = 0.8,
  },
  implement = {
    enable = true,
    sign = true,
  },
  lightbulb = {
    debounce = 3000, -- lightbulb can be noisy and/or cause performance issues, so let's throttle it
  },
  outline = {
    close_after_jump = false,
    keys = {
      toggle_or_jump = "<CR>",
    },
    win_width = 45,
  },
  symbol_in_winbar = {
    enable = true,
  },
  ui = {
    border = "rounded",
  },
});

require("neodev").setup({
  library = {
    plugins = {
      "nvim-dap-ui"
    },
    types = true
  },
})

-- Find the most recently installed cpptools vscode plugin
local function get_cpptools_path()
  local cpptools = vim.fn.glob("~/.vscode/extensions/ms-vscode.cpptools*")

  local max = nil
  local toolspath = nil
  for entry in cpptools:gmatch("[^\r\n]+") do -- glob() returns a string, so we need to split it
    local ftime = vim.fn.getftime(entry)
    if max == nil or ftime > max then
      toolspath = entry
      max = ftime
    end
  end

  if toolspath == nil then
    return "/CPPTOOLS_NOT_FOUND"
  end

  return toolspath
end

local dap = require('dap')
dap.adapters = {
  -- vscode cpptools DAP, per
  -- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
  cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = get_cpptools_path() .. '/debugAdapters/bin/OpenDebugAD7',
  },
  -- Native GDB DAP; doesn't seem to be quite as good as the vscode cpptools
  gdb = {
    id = 'gdb',
    type = 'executable',
    command = '/usr/bin/gdb',
    args = { '-i', 'dap' },
  },
  lldb = {
    id = 'lldb',
    type = 'executable',
    command = '/usr/bin/lldb-vscode',
  },
  codelldb = {
    executable = {
      command = '/usr/sbin/codelldb',
      args = { "--port", "${port}" },
      -- On windows you may have to uncomment this:
      -- detached = false,
    },
    id = 'codelldb',
    port = "${port}",
    type = 'server'
  },
  python = {
    id = 'python',
    type = 'executable',
    command = '/tmp/venv/bin/python',
    args = { '-m', 'debugpy.adapter' },
    options = {
      source_filetype = 'python',
    },
  }
}

-- Better Json support for nvim-dap, per
-- https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#dap
require("dap.ext.vscode").json_decode = require("overseer.json").decode
require('dap.ext.vscode').load_launchjs(nil, {
  cppdbg = { "c", "cpp" },
  python = { "python" },
})

-- Per https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#ccrust-via-lldb-vscode
dap.configurations.c = dap.configurations.cpp
dap.configurations.rust = dap.configurations.cpp

local dapui = require("dapui")
dapui.setup()
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
require("nvim-dap-virtual-text").setup({
  all_frames = true,
  all_references = true,
  highlight_new_as_changed = true,
  only_first_definition = false,
})

vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '🛑', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '🔶', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '🟠', texthl = '', linehl = 'debugPC', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '🔘', texthl = '', linehl = '', numhl = '' })

require("dressing").setup()
require("notify").setup({
  background_colour = "#000000",
})
vim.notify = require("notify");
require('overseer').setup({
  task_list = {
    default_detail = 2,
  },
})


-- vscode.nvim
local customPalette = {
  lime = "#3AF514", -- I use #00FF00 in visual studio, but I like this shade more
  visualStudioDarkPurple = "#BEB7FF"
}
local vscPalette = require("vscode.colors").get_colors();

-- Leverage Treesitter and LSP semantic tokens for even more powerful highlighting.
-- Based on https://github.com/nvim-treesitter/nvim-treesitter#highlight
-- and https://github.com/theHamsta/nvim-semantic-tokens
--
-- You can use :Inspect to view highlight info under the cursor and :InspectTree
-- to view Treesitter nodes, both of which I used to figure out the mappings below.
-- In general, more specific qualifications for a group will take precedence, but
-- these priorities can be queried using the aforementioned functions.
--
-- N.B. these get fed into `vim.api.nvim_set_hl(0, <key>, <valueobject>)` under
-- the hood. So if something breaks, these color tweaks can also be set up
-- manually.
local group_overrides = {
  -- Treesitter nodes
  ["@attribute.cpp"] = { link = "@type.qualifier" }, -- C++ [[attributes]]
  ["@label.cpp"] = { fg = vscPalette.vscRed },       -- `goto` labels
  ["@namespace.cpp"] = { fg = vscPalette.vscDarkYellow },
  ["@operator.cpp"] = { link = "@keyword.cpp" },     -- Includes `&` and `*`
  -- ["@punctuation.bracket.cpp"] = { fg = vscPalette.vscDarkYellow }, -- `{}`, `[]`, `()`
  ["@text.uri"] = { fg = vscPalette.vscAccentBlue },

  -- LSP semantic tokens (these are specific to clangd; no idea if other LSPs will provide these same values)
  ["@lsp.mod.functionScope.cpp"] = { fg = vscPalette.vscFront }, -- regular function scope variables should be white
  ["@lsp.mod.static.cpp"] = { fg = customPalette.lime },         -- Use bright green for statics
  ["@lsp.type.comment.cpp"] = { fg = vscPalette.vscGray },       -- Inactive #ifdefs, etc.
  ["@lsp.type.enum.cpp"] = { fg = vscPalette.vscOrange },        -- Name of an enum...
  ["@lsp.type.enumMember.cpp"] = { link = "@constant.cpp" },     -- ...and the enum values
  ["@lsp.type.macro.cpp"] = { fg = customPalette.visualStudioDarkPurple },
  ["@lsp.type.namespace.cpp"] = { link = "@namespace.cpp" },
  ["@lsp.typemod.class.deduced.cpp"] = { link = "@type.builtin.cpp" },                      -- `auto` type, etc. N.B. that `auto` may be highlighted differently if it resolves to a type with more specific highlighting rules!
  ["@lsp.typemod.parameter.functionScope.cpp"] = { link = "Identifier" },                   -- Parameters should have a little highlighting
  ["@lsp.typemod.property.classScope.cpp"] = { fg = vscPalette.vscLightBlue, bold = true }, -- Member variables should be bold identifiers
  ["@lsp.typemod.type.deduced.cpp"] = { link = "@type.builtin.cpp" },                       -- Other uses of `auto`
  ["@lsp.typemod.type.defaultLibrary.cpp"] = { link = "@type.cpp" },                        -- Types from the standard library shouldn't have special highlighing
  ["@lsp.typemod.type.functionScope.cpp"] = { link = "@type.cpp" },                         -- Type aliases
  ["@lsp.typemod.typeParameter.functionScope.cpp"] = { link = "@type.cpp" },                -- Type parameters
  ["@lsp.typemod.variable.readonly.cpp"] = { link = "@constant.cpp" },                      -- const variables
}

-- Link certain C highlight groups to their C++ equivalents
local c_cpp_overrides = { "label", "operator", "lsp.mod.functionScope", "lsp.mod.static",
  "lsp.type.comment", "lsp.type.enum", "lsp.type.enumMember", "lsp.type.macro",
  "lsp.typemod.parameter.functionScope", "lsp.typemod.type.defaultLibrary",
  "lsp.typemod.type.functionScope", "lsp.typemod.variable.readonly",
}
for _, attr in ipairs(c_cpp_overrides) do
  local cattr = "@" .. attr .. ".c"
  group_overrides[cattr] = { link = cattr .. "pp" }
end

require('vscode').setup({
  style = "dark",
  transparent = true,
  italic_comments = true,
  group_overrides = group_overrides,
})
require("vscode").load()

local lualine_theme = require("lualine.themes.vscode")
lualine_theme.insert.a.bg = vscPalette.vscRed
lualine_theme.insert.b.fg = vscPalette.vscRed
require("lualine").setup({
  extensions = {
    "fugitive", "fzf", "man", "nvim-tree", "nvim-dap-ui", "quickfix", "trouble"
  },
  options = {
    theme = lualine_theme,
  },
  sections = {
    lualine_b = {
      "branch",
      "diff",
      {
        "diagnostics",
        sources = { "nvim_lsp", "nvim_diagnostic", "nvim_workspace_diagnostic" },
        symbols = { error = "E", warn = "W", info = "I", hint = "H" },
        -- update_in_insert = true,
      },
    },
    lualine_c = {
      {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 1,
        symbols = {
          modified = "[+]",
          readonly = "",
          unnamed = "[No Name]",
          newfile = "[New]"
        },
      }
    },
  },
  tabline = {
    lualine_a = {
      {
        "buffers",
        show_filename_only = true,
        hide_filename_extension = false,
        show_modified_status = true,
        mode = 2, -- show buffer name + index
        max_length = vim.o.columns,
        filetype_names = {
          fugitiveblame = " ",
          NvimTree = "🌲",
          TelescopePrompt = "🔭",
        },
        use_mode_colors = true,
      }
    },
  },
})
