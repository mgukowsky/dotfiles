return {
  "rcarriga/nvim-notify",
  event = "VeryLazy",
  keys = {
    {"<M-a>", function() require("notify").dismiss() end, desc = "Dismiss notifications"},
  },
  config = function()
    local notify = require("notify")
    notify.setup({
      background_colour = "#000000",
    })
    vim.notify = notify
  end
}
