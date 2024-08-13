return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "benfowler/telescope-luasnip.nvim",
      -- TODO: this needs DAP to be loaded, so load it as part of DAP
      "nvim-telescope/telescope-dap.nvim",
      "2kabhishek/nerdy.nvim",
    },
    keys = {
      { "<C-p>",            function() require("telescope.builtin").find_files() end,         desc = "Find files" },
      -- Similar to the bash shortcut
      { "<leader>a",        function() require("telescope.builtin").grep_string() end,        desc = "Grep word under cursor" },
      { "<leader>b",        function() require("telescope.builtin").buffers() end,            desc = "Show buffers" },
      -- Similar to VSCode Ctrl+Shift+P
      { "<leader>p",        function() require("telescope.builtin").commands() end,           desc = "Vim command search" },
      { "<leader>r",        function() require("telescope.builtin").command_history() end,    desc = "Command history" },
      { "<leader>s",        function() require("telescope").extensions.luasnip.luasnip() end, desc = "Snippet search" },
      { "<leader>w",        function() require("telescope.builtin").live_grep() end,          desc = "Live grep" },
      { "<leader>.",        function() require("telescope.builtin").symbols() end,            desc = "Symbol/emoji search" },
      { "<leader><M-.>",    "<cmd>Telescope nerdy<CR>",                                       desc = "Nerd font glyph search" },
      { "<leader><leader>", function() require("telescope.builtin").builtin() end,            desc = "Telescope picker search" },
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
      telescope.load_extension("dap")
      telescope.load_extension("luasnip")
      telescope.load_extension("ui-select")
      telescope.load_extension("nerdy")
    end
  },
  {
    -- Nerd font glyph selector
    {
      '2kabhishek/nerdy.nvim',
      dependencies = {
        'stevearc/dressing.nvim',
      },
      cmd = 'Nerdy',
    },
  }
}
