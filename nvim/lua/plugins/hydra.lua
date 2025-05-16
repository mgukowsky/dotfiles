local NAVKEY = ""

return {
  "nvimtools/hydra.nvim",
  lazy = false,
  config = function()
    local hydra = require("hydra")

    hydra({
      name = "Window nav",
      mode = { "n" },
      body = "<C-w>",
      config = {
        -- Make window nav timeout behavior similar to what tmux does
        timeout = 1000,
      },
      heads = {
        -- move between windows
        { "h",     "<C-w>h" },
        { "j",     "<C-w>j" },
        { "k",     "<C-w>k" },
        { "l",     "<C-w>l" },

        -- exit this Hydra
        { "q",     nil,     { exit = true, nowait = true } },
        { "<Esc>", nil,     { exit = true, nowait = true } },
      }
    })
  end,
}
