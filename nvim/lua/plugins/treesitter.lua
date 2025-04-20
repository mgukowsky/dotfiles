return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "folke/which-key.nvim",
      "RRethy/nvim-treesitter-endwise",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "asm",
          "bash",
          "c",
          "cmake",
          "comment",
          "cpp",
          "glsl",
          "javascript",
          "json",
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
        },
        highlight = {
          enable = not vim.g.vscode,
          additional_vim_regex_highlighting = false,
        },
        -- indent = { enable = true } --TODO: use this?
        sync_install = false,
        textobjects = {
          move = {
            enable = true,
            set_jumps = true, -- set jumps in jumplist
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function start" },
            },
            goto_next_end = {
              ["]F"] = { query = "@function.outer", desc = "Next function end" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Previous function start" },
            },
            goto_previous_end = {
              ["[F"] = { query = "@function.outer", desc = "Previous function end" },
            },
          },
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["ab"] = { query = "@block.outer", desc = "Select an entire block" },
              ["ib"] = { query = "@block.inner", desc = "Select the body of a block" },
              ["af"] = { query = "@function.outer", desc = "Select an entire function" },
              ["if"] = { query = "@function.inner", desc = "Select a function body" },
              ["ac"] = { query = "@class.outer", desc = "Select an entire class" },
              ["ic"] = { query = "@class.inner", desc = "Select the body of a class" },
              ["a#"] = { query = "@comment.outer", desc = "Select an entire comment" },
              ["i#"] = { query = "@comment.inner", desc = "Select the body of a comment" },
              ["iS"] = { query = "@statement.outer", desc = "Select the current statement" },
              ["aS"] = { query = "@scope", query_group = "locals", desc = "Select the current scope" },
            },
            include_surrounding_whitespace = false,
          },
        },
        -- Turn on nvim-treesitter-endwise
        endwise = {
          enable = true,
        },
      })
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
  },
  {
    "RRethy/nvim-treesitter-endwise",
    event = "VeryLazy",
  }
}
