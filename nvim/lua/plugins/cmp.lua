return {
  {
    'saghen/blink.cmp',
    dependencies = {
      'rafamadriz/friendly-snippets',
      "L3MON4D3/LuaSnip",
    },

    -- use a release tag to download pre-built binaries
    version = '*',
    config = function()
      -- TODO: this allows snippets to be searched in telescope-luasnip.nvim, but causes snippets to appear twice in the completion list...
      require("luasnip.loaders.from_vscode").lazy_load() -- loads friendly-snippets

      require("blink.cmp").setup({
        keymap = {
          preset = 'default',

          -- https://www.reddit.com/r/neovim/comments/1hk1t35/a_custom_blink_config/
          ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
          ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
          ["<CR>"] = { "accept", "fallback" },
          -- ["<Esc>"] = { "hide", "fallback" },
          -- C-b and C-f are still used to scroll docs
        },

        appearance = {
          kind_icons = {
            Snippet = "🤓",
          },
          -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
          -- Adjusts spacing to ensure icons are aligned
          nerd_font_variant = 'mono',
          -- Sets the fallback highlight groups to nvim-cmp's highlight groups
          -- Useful for when your theme doesn't support blink.cmp
          -- Will be removed in a future release
          use_nvim_cmp_as_default = true,
        },

        completion = {
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
            window = {
              border = "rounded",
            },
          },
          list = {
            max_items = 25,
            selection = "auto_insert",
          },
          menu = {
            border = "rounded",
          },
        },

        -- Signature help, not stable enough yet to replace LSP plugin...
        -- TODO: how to select overload?
        -- signature = {
        --   enabled = true,
        --   window = {
        --     border = "rounded",
        --   },
        -- },

        -- Default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        -- N.B. that the 'buffer' option is smart and will only be used when needed (e.g. when LSP returns no matches)
        sources = {
          default = { 'lsp', 'path', 'snippets', 'luasnip', 'buffer' },
          min_keyword_length = 1,
        },
        snippets = {
          expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
          active = function(filter)
            if filter and filter.direction then
              return require('luasnip').jumpable(filter.direction)
            end
            return require('luasnip').in_snippet()
          end,
          jump = function(direction) require('luasnip').jump(direction) end,
        },
      })
    end,
    opts_extend = { "sources.default" }
  },
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
  },

}
