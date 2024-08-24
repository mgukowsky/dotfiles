-- which-key.nvim
-- Shows completions for a command as characters are entered
-- (after vim.o.timeoutlen); can also be manually invoked with
-- :WhichKey <partial command...>
-- Also adds hooks in normal mode: will show marks when ` is pressed, and
-- registers when " is pressed, and will also show a menu for spelling suggestions
-- when z= is pressed
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
        notify = true,
        sort = { "alphanum", "mod" },
      })

      -- Group descriptions for mappings given as "keys" args in a lazy spec need to be defined here
      wk.add({
        { "<leader>c",  group = "ChatGPT" },
        { "<leader>d",  group = "Debugger (DAP)" },
        { "<leader>db", group = "Breakpoints" },
        { "<leader>df", group = "Frames" },
        { "<leader>dq", group = "DAP commands" },
        { "<leader>h",  group = "Git Hunk operations" },
        { "<leader>o",  group = "Overseer runner (tasks.json)" },
        { "<leader>q",  group = "Extended functionality" },
      })
    end
  }
}
