-- Opens a trouble window; will focus if the command is sent twice/the dialog is already open
local function trouble_toggle(mode)
  local trouble = require("trouble")
  trouble.open({ mode = mode, focus = trouble.is_open({ mode = mode }) })
end

return {
  "folke/trouble.nvim",
  opts = {},
  cmd = "Trouble",
  keys = {
    {
      "q",
      function()
        local trouble = require("trouble")
        if trouble.is_open() then
          trouble.close()
        else
          trouble.open("qflist")
        end
      end,
      desc = "Close window/qflist"
    },
    { "gO",  function() trouble_toggle("lsp_document_symbols") end,             desc = "Document Symbols" },
    { "grc", function() trouble_toggle("lsp_incoming_calls") end,               desc = "Incoming Calls" },
    { "grd", function() trouble_toggle("diagnostics") end,                      desc = "Diagnostics" },
    { "grD", function() vim.cmd("Trouble diagnostics toggle filter.buf=0") end, desc = "Diagnostics (current buffer)" },
    { "gri", function() trouble_toggle("lsp_implementations") end,              desc = "Implementations" },
    { "grl", function() trouble_toggle("loclist") end,                          desc = "Location List" },
    { "gro", function() trouble_toggle("lsp_outgoing_calls") end,               desc = "Incoming Calls" },
    { "grq", function() trouble_toggle("qflist") end,                           desc = "Quickfix List" },
    { "grr", function() trouble_toggle("lsp_references") end,                   desc = "References" },
    { "grs", function() trouble_toggle("symbols") end,                          desc = "Symbols" },
    { "grt", function() vim.cmd("Trouble") end,                                 desc = "Trouble picker" },

    -- Motions from https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/editor.lua#L214
    {
      "[q",
      function()
        if require("trouble").is_open() then
          require("trouble").prev({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cprev)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Previous Trouble/Quickfix Item",
    },
    {
      "]q",
      function()
        if require("trouble").is_open() then
          require("trouble").next({ skip_groups = true, jump = true })
        else
          local ok, err = pcall(vim.cmd.cnext)
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end
      end,
      desc = "Next Trouble/Quickfix Item",
    },
  }
}
