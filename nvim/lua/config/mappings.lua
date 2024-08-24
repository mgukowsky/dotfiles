-- Corresponds to ":noremap"
local map = vim.keymap.set

-- Easy buffer navigation
map("n", "<C-h>", vim.cmd.bp, { desc = "Previous buffer" })
map("n", "<C-l>", vim.cmd.bn, { desc = "Next buffer" })

-- Show Lazy UI
map("n", "<leader>z", function() require("lazy").home() end, { desc = "Lazy UI" })

-- Use arrows for resizing splits instead of navigation; vim "hard mode" ;)
map("n", "<Up>", function() vim.cmd.resize(-2) end, { desc = "Resize horizontal up" })
-- '+2' needs to be passed as a string, otherwise the vim side will interpret this as setting
-- the size to 2
map("n", "<Down>", function() vim.cmd.resize("+2") end, { desc = "Resize horizontal down" })
map("n", "<Left>",
  function()
    vim.cmd({ cmd = "resize", args = { "-2" }, mods = { vertical = true } })
  end, { desc = "Resize vertical left" })
map("n", "<Right>",
  function()
    vim.cmd({ cmd = "resize", args = { "+2" }, mods = { vertical = true } })
  end, { desc = "Resize vertical right" })
