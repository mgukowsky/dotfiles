-- Autocommands live here

-- Corresponds to ":au"
local au = vim.api.nvim_create_autocmd

-- Invoke Limelight as part of Goyo
au("User", {
  pattern = "GoyoEnter",
  command = "Limelight"
})
au("User", {
  pattern = "GoyoLeave",
  command = "Limelight!"
})

-- Enable spellchecking for specific filetypes
au("FileType", {
  pattern = "markdown,text",
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end
})

-- File types for rare extensions
local function setft(ext, syntax) -- Set syntax association for a given filetype
  au("BufReadPost", {
    pattern = { ext },
    callback = function() vim.opt.syntax = syntax end
  })
end

setft("*.manifest", "xml")
setft("*.zsh-theme", "sh")
setft(".clang-format", "yaml")
setft(".gitmessage", "gitcommit")
