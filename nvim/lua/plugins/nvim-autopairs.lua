return {
  'windwp/nvim-autopairs',
  event = "InsertEnter",
  config = function()
    local npairs = require("nvim-autopairs")
    npairs.setup({
      -- Don't add the closing pair if the next character is alphanumeric or '.'
      -- This is usually what we want
      ignored_next_char = "[%w%.]",
    })

    local endwise = require("nvim-autopairs.ts-rule").endwise
    npairs.add_rules({
      -- For C++ files, add a matching #endif to #if directives
      -- Not covered by nvim-treesitter-endwise, so we have to add it
      -- Per https://github.com/windwp/nvim-autopairs/wiki/Endwise#create-a-new-endwise-rule
      endwise("^#if.*$", "#endif", "cpp", "preproc_if"),
    })
  end
}
