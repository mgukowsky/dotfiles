return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
    opts = {
      extensions = {
        "fugitive",
        "fzf",
        "man",
        "nvim-tree",
        "nvim-dap-ui",
        "quickfix",
        "trouble",
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
          -- {
            -- dap_status_comp,
            -- color = { fg = vscPalette.vscDarkYellow },
          -- },
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
    }
  }
}
