local M = {}

-- Flag to ensure that bootstrapping is performed once, and before setup
M.is_lazy_bootstrapped = false

-- lazy.nvim bootstrap, per https://lazy.folke.io/installation
function M.bootstrap_lazy()
  if not is_lazy_bootstrapped then
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    end
    vim.opt.rtp:prepend(lazypath)
  end
  is_lazy_bootstrapped = true
end

-- Setup lazy.nvim
function M.setup_lazy()
  if not is_lazy_bootstrapped then
    M.bootstrap_lazy()
  end

  require("lazy").setup({
    spec = {
      -- import your plugins
      { import = "plugins" },
    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    -- install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
  })
end

return M
