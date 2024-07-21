return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-symbols.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "benfowler/telescope-luasnip.nvim",
    -- TODO: this needs DAP to be loaded, so load it as part of DAP
    -- "nvim-telescope/telescope-dap.nvim",
  },
  keys = {
    {"<C-p>", function() require("telescope.builtin").find_files() end, desc = "Find files"},
		-- Similar to the bash shortcut
    {"<leader>a", function() require("telescope.builtin").grep_string() end, desc = "Grep word under cursor"},
  },
  config = function()
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

    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        vimgrep_arguments = vimgrep_arguments,
        mappings = {
          i = {
            ["<esc>"] = "close", -- Close the popup instead of first going to normal mode
            ["<C-j>"] = "move_selection_next",
            ["<C-k>"] = "move_selection_previous",
          },
        },
      },
      extensions = {
        -- Use telescope for vim.ui.select()
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
      pickers = {
        find_files = {
          find_command = { "rg", "--files", HIDDEN, GLOB, GIT_DIR_REGEX },
        },
      },
    })
    -- telescope.load_extension("dap")
    telescope.load_extension("luasnip")
    telescope.load_extension("ui-select")
  end
}
