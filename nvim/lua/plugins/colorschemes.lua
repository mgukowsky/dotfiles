local function create_group_overrides(colors)
  -- Leverage Treesitter and LSP semantic tokens for even more powerful highlighting.
  -- Based on https://github.com/nvim-treesitter/nvim-treesitter#highlight
  -- and https://github.com/theHamsta/nvim-semantic-tokens
  --
  -- You can use :Inspect to view highlight info under the cursor and :InspectTree
  -- to view Treesitter nodes, both of which I used to figure out the mappings below.
  -- In general, more specific qualifications for a group will take precedence, but
  -- these priorities can be queried using the aforementioned functions.
  --
  -- N.B. these get fed into `vim.api.nvim_set_hl(0, <key>, <valueobject>)` under
  -- the hood. So if something breaks, these color tweaks can also be set up
  -- manually.
  local group_overrides = {
    -- Highlight groups
    ["BreakpointSet"] = { bg = "#762c2c" },
    -- Treesitter nodes
    ["@attribute.cpp"] = { link = "@type.qualifier" }, -- C++ [[attributes]]
    ["@label.cpp"] = { fg = colors.bright_red },       -- `goto` labels
    ["@namespace.cpp"] = { fg = colors.dark_yellow, italic = true },

    -- Treesitter update in ~2024 gave some keywords different highlighting; let's make all keywords
    -- use the same highlighting
    ["@keyword.cpp"] = { link = "@keyword.return" },
    ["@operator.cpp"] = { link = "@keyword.cpp" }, -- Includes `&` and `*`
    ["@lsp.type.operator.cpp"] = { link = "@operator.cpp" },
    ["@operator.rust"] = { link = "@operator.cpp" },
    -- ["@punctuation.bracket.cpp"] = { fg = vscPalette.vscDarkYellow }, -- `{}`, `[]`, `()`
    ["@text.uri"] = { fg = colors.accent_blue },

    -- LSP semantic tokens (these are specific to clangd; no idea if other LSPs will provide these same values)
    ["@lsp.mod.functionScope.cpp"] = { fg = colors.fg }, -- regular function scope variables should be white
    ["@lsp.type.variable.rust"] = { link = "@lsp.mod.functionScope.cpp" },
    ["@lsp.mod.static.cpp"] = { fg = colors.lime },      -- Use bright green for statics
    ["@lsp.type.comment.cpp"] = { fg = colors.comment }, -- Inactive #ifdefs, etc.
    ["@lsp.type.enum.cpp"] = { fg = colors.orange },     -- Name of an enum...
    ["@lsp.type.enum.rust"] = { link = "@lsp.type.enum.cpp" },
    ["@lsp.type.decorator.rust"] = { link = "@attribute.cpp" },
    ["@lsp.type.enumMember.cpp"] = { link = "@constant.cpp" }, -- ...and the enum values
    ["@lsp.type.macro.cpp"] = { fg = colors.dark_purple, bold = true },
    ["@lsp.type.macro.rust"] = { link = "@lsp.type.macro.cpp" },
    ["@lsp.type.namespace.cpp"] = { link = "@namespace.cpp" },
    ["@lsp.type.namespace.rust"] = { link = "@lsp.type.namespace.cpp" },
    ["@lsp.typemod.class.deduced.cpp"] = { link = "@type.builtin.cpp" },                -- `auto` type, etc. N.B. that `auto` may be highlighted differently if it resolves to a type with more specific highlighting rules!
    ["@lsp.typemod.parameter.functionScope.cpp"] = { link = "Identifier" },             -- Parameters should have a little highlighting
    ["@lsp.type.parameter.rust"] = { link = "@lsp.typemod.parameter.functionScope.cpp" },
    ["@lsp.typemod.property.classScope.cpp"] = { fg = colors.light_blue, bold = true }, -- Member variables should be bold identifiers
    ["@lsp.typemod.type.deduced.cpp"] = { link = "@type.builtin.cpp" },                 -- Other uses of `auto`
    ["@lsp.typemod.type.defaultLibrary.cpp"] = { link = "@type.cpp" },                  -- Types from the standard library shouldn't have special highlighing
    ["@lsp.typemod.type.functionScope.cpp"] = { link = "@type.cpp" },                   -- Type aliases
    ["@lsp.typemod.typeParameter.functionScope.cpp"] = { link = "@type.cpp" },          -- Type parameters
    ["@lsp.typemod.variable.readonly.cpp"] = { link = "@constant.cpp" },                -- const variables
  }

  -- Link certain C highlight groups to their C++ equivalents
  local c_cpp_overrides = {
    "label",
    "operator",
    "lsp.mod.functionScope",
    "lsp.mod.static",
    "lsp.type.comment",
    "lsp.type.enum",
    "lsp.type.enumMember",
    "lsp.type.macro",
    "lsp.typemod.parameter.functionScope",
    "lsp.typemod.type.defaultLibrary",
    "lsp.typemod.type.functionScope",
    "lsp.typemod.variable.readonly",
  }

  for _, attr in ipairs(c_cpp_overrides) do
    local cattr = "@" .. attr .. ".c"
    group_overrides[cattr] = { link = cattr .. "pp" }
  end

  return group_overrides
end

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- Colors defined here will be passed to `on_highlights`
      on_colors = function(colors)
        local palette = require("tokyonight.colors.night")
        colors.fg = palette.fg
        colors.accent_blue = palette.blue2
        colors.bright_red = "#FF0000"
        colors.dark_purple = palette.magenta
        colors.dark_yellow = palette.orange
        colors.comment = palette.comment
        colors.light_blue = palette.blue1
        colors.lime = "#3AF514"
        colors.orange = palette.red
      end,
      on_highlights = function(hl, c)
        local group_overrides = create_group_overrides(c)
        for k, v in pairs(group_overrides) do
          hl[k] = v
        end
      end
    },
  },
  -- {
  --   "Mofiqul/vscode.nvim",
  --   lazy = false,
  --   priority = 1000,
  --   config = function()
  --     local vscPalette = require("vscode.colors").get_colors()
  --
  --     require("vscode").setup({
  --       style = "dark",
  --       -- transparent = true,
  --       italic_comments = true,
  --       group_overrides = create_group_overrides({
  --         fg = vscPalette.vscFront,
  --         accent_blue = vscPalette.vscAccentBlue,
  --         bright_red = vscPalette.vscRed,
  --         dark_purple = "#BEB7FF",
  --         dark_yellow = vscPalette.vscDarkYellow,
  --         comment = vscPalette.vscGray,
  --         light_blue = vscPalette.vscLightBlue,
  --         lime = "#3AF514",
  --         orange = vscPalette.vscOrange,
  --       }),
  --     })
  --   end
  -- },
  {
    "Shatur/neovim-ayu",
    lazy = false,
    priority = 1000,
    config = function()
      local palette = require("ayu.colors")
      palette.generate(false)

      require("ayu").setup({
        overrides = create_group_overrides({
          fg = palette.fg,
          accent_blue = palette.entity,
          bright_red = "#FF0000",
          dark_purple = palette.lsp_parameter,
          dark_yellow = palette.accent,
          comment = palette.comment,
          light_blue = palette.regexp,
          lime = "#3AF514",
          orange = palette.warning,

        })
      })
    end
  },
  {
    "RRethy/base16-nvim",
    lazy = false,
    priority = 1000,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        styles = {
          comments = "italic",
          keywords = "bold",
          types = "italic,bold",
        }
      }
    }
  },
  {
    -- N.B. this will highlight certain keywords with a 'glow' effect
    "lunarvim/synthwave84.nvim",
    lazy = false,
    priority = 1000,
    config = true,
  },
  {
    -- Also includes 'glow' effects
    "maxmx03/fluoromachine.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      glow = true,
      -- One of [fluoromachine|retrowave|delta]
      theme = "fluoromachine",
      transparent = false,
    }
  },
  {
    "adamkali/vaporlush",
    dependencies = {
      "rktjmp/lush.nvim",
    },
  },
  {
    "slugbyte/lackluster.nvim",
    lazy = false,
    priority = 1000,
    config = true,
  },
}
