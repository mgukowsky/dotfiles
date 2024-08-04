return {
  'lewis6991/gitsigns.nvim',
  dependencies = {
    "folke/which-key.nvim",
  },
  event = "VeryLazy",
  keys = {
    {"<leader>hb", function() require("gitsigns").blame_line() end, desc = "Show blame"},
    {"<leader>hB", function() require("gitsigns").blame_line({ full = true }) end, desc = "Show full blame"},
    {"<leader>hd", function() require("gitsigns").toggle_deleted() end, desc = "Toggle show deleted hunks"},
    {"<leader>hD", function() require("gitsigns").diffthis() end, desc = "Vimdiff current line"},
    {"<leader>hp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk"},
    {"<leader>hr", function() require("gitsigns").undo_stage_buffer() end, desc = "Undo stage buffer"},
    {"<leader>hR", function() require("gitsigns").reset_buffer() end, desc = "Reset buffer"},
    {"<leader>hs", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk"},
    {"<leader>hS", function() require("gitsigns").stage_buffer() end, desc = "Stage buffer"},
    {"<leader>hu", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk"},
    -- Hunk text object
    { "ih", ":<C-U>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "Select git hunk" }
  },
  config = function()
    local gs = require("gitsigns")
    gs.setup({
      numhl = true,
    })
    local next_hunk_repeat, prev_hunk_repeat =
      require("nvim-treesitter.textobjects.repeatable_move").make_repeatable_move_pair(gs.next_hunk, gs.prev_hunk)

    require("which-key").add({
      { "[c", function() prev_hunk_repeat() end, desc = "Prev Git change" },
      { "]c", function() next_hunk_repeat() end, desc = "Next Git change" },
    })
  end
}
