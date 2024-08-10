-- Get YAML schema for current buffer, per https://www.arthurkoziel.com/json-schemas-in-neovim/
local function get_schema()
	local schema = require("yaml-companion").get_buf_schema(0)
	local name = schema.result[1].name
	if name == "none" then
		return ""
	else
		return "📜" .. name
	end
end

return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'someone-stole-my-name/yaml-companion.nvim',
      'nvim-tree/nvim-web-devicons',
      'Mofiqul/vscode.nvim',
      'mfussenegger/nvim-dap',
    },
    config = function()
      local vscPalette = require("vscode.colors").get_colors()
      local lualine_theme = require("lualine.themes.vscode")

      lualine_theme.insert.a.bg = vscPalette.vscRed
      lualine_theme.insert.b.fg = vscPalette.vscRed

      -- Custom lualine component to show DAP status
      local dap_status_comp = require("lualine.component"):extend()
      function dap_status_comp:init(options)
        dap_status_comp.super.init(self, options)
      end

      function dap_status_comp:update_status()
        return require("dap").status()
      end

      require("lualine").setup({
        extensions = {
          "fugitive",
          "fzf",
          "man",
          "nvim-tree",
          "nvim-dap-ui",
          "quickfix",
          "trouble",
        },
        options = {
          theme = lualine_theme
        },
        sections = {
          lualine_b = {
            "branch",
            "diff",
            {
              "diagnostics",
              sources = { "nvim_lsp", "nvim_diagnostic" },
              symbols = { error = "E", warn = "W", info = "I", hint = "H" },
              -- update_in_insert = true,
            },
          },
          lualine_c = {
            {
              "filename",
              file_status = true,
              newfile_status = true,
              path = 1,
              symbols = {
                modified = "[+]",
                readonly = "",
                unnamed = "[No Name]",
                newfile = "[New]",
              },
            },
            {
              dap_status_comp,
              color = { fg = vscPalette.vscDarkYellow },
            },
          },
          lualine_x = { "encoding", "fileformat", "filetype", get_schema },
        },
        tabline = {
          lualine_a = {
            {
              "buffers",
              show_filename_only = true,
              hide_filename_extension = false,
              show_modified_status = true,
              mode = 2, -- show buffer name + index
              max_length = vim.o.columns,
              filetype_names = {
                fugitiveblame = " ",
                NvimTree = "🌲",
                TelescopePrompt = "🔭",
              },
              use_mode_colors = true,
            },
          },
        },
      })
    end
  }
}
