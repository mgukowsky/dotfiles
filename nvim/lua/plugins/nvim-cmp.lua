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
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "ray-x/cmp-treesitter",

      -- LuaSnip, to support nvim-cmp
      "L3MON4D3/LuaSnip", --{ ["do"] = "make install_jsregexp" }
      "saadparwaiz1/cmp_luasnip",

      -- Spellchecking for nvim-cmp
      "uga-rosa/cmp-dictionary",
      -- Icons in completion menu
      "onsails/lspkind.nvim",
    },
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
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            menu = {
              buffer = "🔠",
              nvim_lsp = "🐲",
              nvim_lua = "📜",
              luasnip = "🤓",
              dictionary = "📕",
              treesitter = "🎄",
            },
          }),
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
          { name = "nvim_lsp", keyword_length = 1 },
          { name = "treesitter", keyword_length = 2 },
          { name = "nvim_lua", keyword_length = 2 },
          { name = "buffer", keyword_length = 2 },
          { name = "luasnip", keyword_length = 3 },
          { name = "dictionary", keyword_length = 6 },
          { name = "nvim_lsp_signature_help" },
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

      local dict = require("cmp_dictionary")

      dict.setup({})

      local DICTFILEPATH = vim.fn.stdpath("data") .. "/en.dict"

      -- Create the dictionary if it doesn't exist
      -- Beware Lua falsy value rules (only `false` and `nil` are falsy 🙃)
      if vim.fn.filereadable(DICTFILEPATH) == 0 and vim.fn.executable("aspell") == 1 then
        print("Creating dictionary file '" .. DICTFILEPATH .. "' with aspell")
        os.execute("aspell -d en dump master | aspell -l en expand > " .. DICTFILEPATH)
      end

      -- dict.switcher({
      --   -- N.B. that given my locale, vim.opt.spelllang defaults to "en"
      --   spelllang = {
      --     en = DICTFILEPATH
      --   }
      -- })
    end,
  }
}