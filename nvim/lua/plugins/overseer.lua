return {
  "stevearc/overseer.nvim",
  opts = {
    strategy = {
      "toggleterm",
      use_shell = false,
      close_on_exit = false,
      quit_on_exit = "success",
      open_on_start = true,
    },
    task_list = {
      default_detail = 2,
    },
  },
  keys = {
    { "<leader>oc", function() require("overseer").close() end, desc = "Close" },
    { "<leader>oo", function() require("overseer").open() end,  desc = "Open" },
    {
      "<leader>or",
      function()
        local overseer = require("overseer")
        overseer.open()
        overseer.run_template()
      end,
      desc = "Run"
    },
    { "<leader>ot", function() require("overseer").toggle() end, desc = "Toggle" },
  }
}
