-- Build an operator (for use with `g@`) which passes the text covered by a motion to `fn`
local function telescope_operator(fn)
  return function()
    -- 'operatorfunc' is a string option, so it can't hold a Lua closure directly; it must be a global that Vimscript can
    -- reach via `v:lua`. It's reassigned on every invocation so the active operator's `fn` is the one that gets called.
    _G.__telescope_opfunc = function(motion_type)
      -- `g@` passes the motion type as "char", "line", or "block"; getregion() wants the equivalent visual mode
      -- ("\22" is <C-v>, i.e. blockwise)
      local regtype = ({ char = "v", line = "V", block = "\22" })[motion_type]
      -- `g@` sets the '[ and '] marks to the start/end of the motion (or visual selection); fetch the text between them
      local lines = vim.fn.getregion(vim.fn.getpos("'["), vim.fn.getpos("']"), { type = regtype })
      -- ripgrep matches line-by-line, so collapse multi-line selections into a single line
      local text = vim.trim(table.concat(lines, " "))
      fn(text)
    end
    -- `v:lua.<name>` tells Vim to call the global Lua function `<name>` when `g@` fires.
    -- Clobbering this global option is safe and idiomatic (see `:h g@`).
    vim.o.operatorfunc = "v:lua.__telescope_opfunc"
    -- `g@` is Vim's "call 'operatorfunc'" operator: it waits for a motion (or uses the visual selection), then calls it
    return "g@"
  end
end

local grep_string_op = telescope_operator(function(text)
  require("telescope.builtin").grep_string({ search = text })
end)

local live_grep_op = telescope_operator(function(text)
  require("telescope.builtin").live_grep({ default_text = text })
end)

return {
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "benfowler/telescope-luasnip.nvim",
      -- TODO: this needs DAP to be loaded, so load it as part of DAP
      "nvim-telescope/telescope-dap.nvim",
      "2kabhishek/nerdy.nvim",
    },
    keys = {
      { "<C-p>",            function() require("telescope.builtin").find_files() end,         desc = "Find files" },
      -- Similar to the bash shortcut
      { "<leader>a",        grep_string_op,                                                   desc = "Grep motion",            expr = true, mode = { "n", "x" } },
      { "<leader>b",        function() require("telescope.builtin").buffers() end,            desc = "Show buffers" },
      -- Similar to VSCode Ctrl+Shift+P
      { "<leader>p",        function() require("telescope.builtin").commands() end,           desc = "Vim command search" },
      { "<leader>r",        function() require("telescope.builtin").command_history() end,    desc = "Command history" },
      { "<leader>s",        function() require("telescope").extensions.luasnip.luasnip() end, desc = "Snippet search" },
      { "<leader>w",        live_grep_op,                                                     desc = "Live grep motion",       expr = true, mode = { "n", "x" } },
      { "<leader>.",        function() require("telescope.builtin").symbols() end,            desc = "Symbol/emoji search" },
      { "<leader><M-.>",    "<cmd>Telescope nerdy<CR>",                                       desc = "Nerd font glyph search" },
      { "<leader><leader>", function() require("telescope.builtin").builtin() end,            desc = "Telescope picker search" },
    },
    config = function()
      local telescopeConfig = require("telescope.config")
      local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

      local HIDDEN = "--hidden"
      local GLOB = "--glob"
      local GIT_DIR_REGEX = "!**/.git/*"

      -- I want to search in hidden/dot files.
      table.insert(vimgrep_arguments, HIDDEN)
      -- I don't want to search in the `.git` directory.
      table.insert(vimgrep_arguments, GLOB)
      table.insert(vimgrep_arguments, GIT_DIR_REGEX)

      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          vimgrep_arguments = vimgrep_arguments,
          mappings = {
            i = {
              ["<esc>"] = "close", -- Close the popup instead of first going to normal mode
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
        extensions = {
          -- Use telescope for vim.ui.select()
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
        pickers = {
          find_files = {
            find_command = { "rg", "--files", HIDDEN, GLOB, GIT_DIR_REGEX },
          },
        },
      })
      telescope.load_extension("dap")
      telescope.load_extension("luasnip")
      telescope.load_extension("ui-select")
      telescope.load_extension("nerdy")
    end
  },
  {
    -- Nerd font glyph selector
    {
      '2kabhishek/nerdy.nvim',
      dependencies = {
        'stevearc/dressing.nvim',
      },
      cmd = 'Nerdy',
    },
  }
}
