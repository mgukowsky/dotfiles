return {
  'lewis6991/gitsigns.nvim',
  dependencies = {
    "folke/which-key.nvim",
  },
  event = "VeryLazy",
  keys = {
    { "<leader>hb", function() require("gitsigns").blame_line() end,                desc = "Show blame" },
    { "<leader>hB", function() require("gitsigns").blame_line({ full = true }) end, desc = "Show full blame" },
    { "<leader>hd", function() require("gitsigns").toggle_deleted() end,            desc = "Toggle show deleted hunks" },
    { "<leader>hD", function() require("gitsigns").diffthis() end,                  desc = "Vimdiff current line" },
    { "<leader>hp", function() require("gitsigns").preview_hunk() end,              desc = "Preview hunk" },
    { "<leader>hr", function() require("gitsigns").undo_stage_buffer() end,         desc = "Undo stage buffer" },
    { "<leader>hR", function() require("gitsigns").reset_buffer() end,              desc = "Reset buffer" },
    { "<leader>hs", function() require("gitsigns").stage_hunk() end,                desc = "Stage hunk" },
    { "<leader>hS", function() require("gitsigns").stage_buffer() end,              desc = "Stage buffer" },
    { "<leader>hu", function() require("gitsigns").reset_hunk() end,                desc = "Reset hunk" },
    { "]C",         function() require("gitsigns").nav_hunk("last") end,            desc = "Last Hunk" },
    { "[C",         function() require("gitsigns").nav_hunk("first") end,           desc = "First Hunk" },

    -- Hunk text object
    { "ih",         ":<C-U>Gitsigns select_hunk<CR>",                               mode = { "o", "x" },               desc = "Select git hunk" }
  },
  config = function()
    local gs = require("gitsigns")
    gs.setup({
      numhl = true,
      signs_staged_enable = false,
      update_debounce = 1000, -- only update once a second
    })
    require("which-key").add({
      {
        "[c",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end,
        desc = "Prev Git change"
      },
      {
        "]c",
        function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end,
        desc = "Next Git change"
      },
    })
  end
}
