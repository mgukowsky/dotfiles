-- LSP progress spinner
-- Can also be used as a `vim.notify` backend
-- Was recently rewritten, and TBH doesn't seem to work too well...
return {
  "j-hui/fidget.nvim",
  event = "VeryLazy",
  -- TODO: Failing to supply a manual config function prevents the plugin from being loaded 0_o
  config = function()
    require("fidget").setup()
  end
}
