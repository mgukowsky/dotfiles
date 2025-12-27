return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- nvim-treesitter main branch does not support lazy-loading
    branch = "main",
    build = ":TSUpdate",
    dependencies = {
      "folke/which-key.nvim",
      "RRethy/nvim-treesitter-endwise",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- Install parsers that were previously in ensure_installed
      -- The main branch no longer has auto_install or ensure_installed in setup
      local ts_parsers = require("local.vars").TS_PARSERS
      require("nvim-treesitter").install(ts_parsers)

      -- Enable treesitter highlighting for all parser filetypes
      -- The main branch requires explicit activation via autocommand
      vim.api.nvim_create_autocmd("FileType", {
        pattern = ts_parsers,
        callback = function()
          vim.treesitter.start()
        end,
        desc = "Enable treesitter highlighting",
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = {
      "folke/which-key.nvim",
    },
    event = "VeryLazy",
    config = function()
      -- Configure textobjects options (not keymaps)
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
          include_surrounding_whitespace = false,
        },
        move = {
          set_jumps = true, -- set jumps in jumplist
        },
      })

      -- Define keymaps using which-key
      local ts_select = require("nvim-treesitter-textobjects.select")
      local ts_move = require("nvim-treesitter-textobjects.move")

      require("which-key").add({
        -- Select textobjects
        { "ab", function() ts_select.select_textobject("@block.outer", "textobjects") end,     mode = { "x", "o" },      desc = "Select an entire block" },
        { "ib", function() ts_select.select_textobject("@block.inner", "textobjects") end,     mode = { "x", "o" },      desc = "Select the body of a block" },
        { "af", function() ts_select.select_textobject("@function.outer", "textobjects") end,  mode = { "x", "o" },      desc = "Select an entire function" },
        { "if", function() ts_select.select_textobject("@function.inner", "textobjects") end,  mode = { "x", "o" },      desc = "Select a function body" },
        { "ac", function() ts_select.select_textobject("@class.outer", "textobjects") end,     mode = { "x", "o" },      desc = "Select an entire class" },
        { "ic", function() ts_select.select_textobject("@class.inner", "textobjects") end,     mode = { "x", "o" },      desc = "Select the body of a class" },
        { "a#", function() ts_select.select_textobject("@comment.outer", "textobjects") end,   mode = { "x", "o" },      desc = "Select an entire comment" },
        { "i#", function() ts_select.select_textobject("@comment.inner", "textobjects") end,   mode = { "x", "o" },      desc = "Select the body of a comment" },
        { "iS", function() ts_select.select_textobject("@statement.outer", "textobjects") end, mode = { "x", "o" },      desc = "Select the current statement" },
        { "aS", function() ts_select.select_textobject("@scope", "textobjects") end,           mode = { "x", "o" },      desc = "Select the current scope" },

        -- Movement keymaps
        { "]f", function() ts_move.goto_next_start("@function.outer", "textobjects") end,      mode = { "n", "x", "o" }, desc = "Next function start" },
        { "]F", function() ts_move.goto_next_end("@function.outer", "textobjects") end,        mode = { "n", "x", "o" }, desc = "Next function end" },
        { "[f", function() ts_move.goto_previous_start("@function.outer", "textobjects") end,  mode = { "n", "x", "o" }, desc = "Previous function start" },
        { "[F", function() ts_move.goto_previous_end("@function.outer", "textobjects") end,    mode = { "n", "x", "o" }, desc = "Previous function end" },
      })
    end
  },
  {
    "RRethy/nvim-treesitter-endwise",
    event = "VeryLazy",
    -- No configuration needed - works automatically
  }
}
