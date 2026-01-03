if G_USE_BLINK then
  return {
    {
      'saghen/blink.cmp',
      dependencies = {
        { "rafamadriz/friendly-snippets", version = "*" },
        { "L3MON4D3/LuaSnip",             version = 'v2.*' },
      },

      -- use a release tag to download pre-built binaries
      version = '*',
      config = function()
        -- TODO: this allows snippets to be searched in telescope-luasnip.nvim es snippets to appear twice in the completion list...
        require("luasnip.loaders.from_vscode").lazy_load() -- loads friendly-s

        require("blink.cmp").setup({
          keymap = {
            preset = 'default',

            -- https://www.reddit.com/r/neovim/comments/1hk1t35/a_custom_blink

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
            -- Sets the fallback highlight groups to nvim-cmp's highlight grou

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
              -- selection = "auto_insert",
            },
            menu = {
              border = "rounded",
            },
          },

          -- Signature help, not stable enough yet to replace LSP plugin...
          -- TODO: how to select overload?
          signature = {
            enabled = true,
            window = {
              border = "rounded",
            },
          },

          -- Default list of enabled providers defined so that you can extend

          -- elsewhere in your config, without redefining it, due to `opts_ext

          -- N.B. that the 'buffer' option is smart and will only be used when .g. when LSP returns no matches)
          sources = {
            default = { 'lsp', 'path', 'snippets', 'buffer' },
            min_keyword_length = 1,
          },
          -- TODO: transition to using vim.snippets support in 0.11
          snippets = { preset = 'luasnip' },
        })
      end,
      opts_extend = { "sources.default" }
    },
  }

  -- Otherwise, fall back to using nvim-cmp
else
  -- nvim-cmp configuration; from https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#safely-select-entries-with-cr
  local function has_words_before()
    unpack = unpack or table.unpack
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  return {
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        -- nvim-cmp plugins
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        -- Conflicts with the lsp_signature.nvim plugin
        -- "hrsh7th/cmp-nvim-lsp-signature-help",
        "ray-x/cmp-treesitter",

        -- LuaSnip, to support nvim-cmp
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",

        "nvim-lua/plenary.nvim",
        -- Icons in completion menu
        "onsails/lspkind.nvim",
      },
      -- Run `:CmpStatus` to get information about this plugin
      cmd = { "CmpStatus" },
      event = { "CmdlineEnter", "InsertEnter" },
      config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        require("luasnip.loaders.from_vscode").lazy_load() -- loads friendly-snippets
        local lspkind = require("lspkind")
        cmp.setup({
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          },
          window = {
            completion = cmp.config.window.bordered({ border = "rounded" }),
            documentation = cmp.config.window.bordered({ border = "rounded" }),
          },
          formatting = {
            format = lspkind.cmp_format({
              mode = "symbol_text",
              menu = {
                buffer = "🔠",
                nvim_lsp = "🐲",
                nvim_lua = "📜",
                lazydev = "📜",
                luasnip = "🤓",
                treesitter = "🎄",
              },
            }),
            expandable_indicator = true,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-e>"] = cmp.mapping.abort(),
            -- Supertab-like config, from the nvim-cmp wiki
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.locally_jumpable(1) then
                luasnip.jump(1)
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
            -- Make <CR> complete the entry if one is selected, otherwise make a newline like normal;
            -- also from the nvim-cmp wiki
            ["<CR>"] = cmp.mapping({
              i = function(fallback)
                if cmp.visible() and cmp.get_active_entry() then
                  cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                else
                  fallback()
                end
              end,
              s = cmp.mapping.confirm({ select = true }),
              -- This mapping seems to break <CR> functionality in other menus, such as the LSPMenu I
              -- create in 50_lsp.lua. Setting this to a function with a fallback doesn't seem to help...
              -- c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
            }),
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp",   keyword_length = 1 },
            { name = "treesitter", keyword_length = 2 },
            { name = "nvim_lua",   keyword_length = 2 },
            { name = "buffer",     keyword_length = 2 },
            { name = "luasnip",    keyword_length = 3 },
            -- { name = "nvim_lsp_signature_help" },
            { name = "lazydev",    group_index = 0 },
          }),
        })
        -- Use buffer for completing "/" and "?" searches
        cmp.setup.cmdline({ "/", "?" }, {
          mapping = cmp.mapping.preset.cmdline(),
          sources = {
            { name = "buffer" },
          },
        })
        -- Use path and cmdline for completing ":" commands
        cmp.setup.cmdline(":", {
          mapping = cmp.mapping.preset.cmdline(),
          sources = cmp.config.sources({
            { name = "path" },
          }, {
            -- Setting keyword_length to a low value can lead to performance issues, since it will try
            -- to match against _all_ possible commands. Observed that `:r!` caused nvim to lock up as
            -- nvim-cmp tried to match it against all possible commands on the system.
            { name = "cmdline", keyword_length = 4 },
          }),
        })
      end,
    },
    {
      "L3MON4D3/LuaSnip",
      build = "make install_jsregexp",
    },
  }
end
