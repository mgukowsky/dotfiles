return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- nvim-treesitter main branch does not support lazy-loading
    branch = "main",
    build = ":TSUpdate",
    -- Parsers are needed in VSCode for the textobjects/flash treesitter motions (vscode-neovim sets the buffer filetype
    -- from the VSCode language ID, so parsers attach as usual)
    vscode = true,
    dependencies = {
      -- N.B. endwise is insert-mode only, so it won't load in VSCode (insert mode is handled by VSCode itself)
      "RRethy/nvim-treesitter-endwise",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      -- Install parsers that were previously in ensure_installed
      -- The main branch no longer has auto_install or ensure_installed in setup
      local ts_parsers = require("local.vars").TS_PARSERS
      require("nvim-treesitter").install(ts_parsers)

      -- VSCode does its own highlighting
      if G_IS_VSCODE then
        return
      end

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
    event = "VeryLazy",
    vscode = true,
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

      -- Define keymaps. These use plain vim.keymap.set (rather than which-key) so that they also work in VSCode, where
      -- which-key isn't loaded; which-key still picks up the `desc` of each mapping in the TUI.
      local ts_select = require("nvim-treesitter-textobjects.select")
      local ts_move = require("nvim-treesitter-textobjects.move")

      local function sel(lhs, query, desc)
        vim.keymap.set({ "x", "o" }, lhs, function() ts_select.select_textobject(query, "textobjects") end,
          { desc = desc })
      end
      local function mv(lhs, fn, query, desc)
        vim.keymap.set({ "n", "x", "o" }, lhs, function() ts_move[fn](query, "textobjects") end, { desc = desc })
      end

      -- Select textobjects
      sel("ab", "@block.outer", "Select an entire block")
      sel("ib", "@block.inner", "Select the body of a block")
      sel("af", "@function.outer", "Select an entire function")
      sel("if", "@function.inner", "Select a function body")
      sel("ac", "@class.outer", "Select an entire class")
      sel("ic", "@class.inner", "Select the body of a class")
      sel("a#", "@comment.outer", "Select an entire comment")
      sel("i#", "@comment.inner", "Select the body of a comment")
      sel("iS", "@statement.outer", "Select the current statement")
      sel("aS", "@scope", "Select the current scope")

      -- Movement keymaps
      mv("]f", "goto_next_start", "@function.outer", "Next function start")
      mv("]F", "goto_next_end", "@function.outer", "Next function end")
      mv("[f", "goto_previous_start", "@function.outer", "Previous function start")
      mv("[F", "goto_previous_end", "@function.outer", "Previous function end")
    end
  },
  {
    "RRethy/nvim-treesitter-endwise",
    event = "VeryLazy",
    -- No configuration needed - works automatically
  }
}
