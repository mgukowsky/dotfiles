return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  -- Run `:ConformInfo` to get information about attached formatters
  cmd = { "ConformInfo", "FormatEnable", "FormatDisable" },
  config = function()
    require("conform").setup({
      -- Define your formatters
      formatters_by_ft = {
        python = { "isort", "black" },
        -- "_" is a wildcard that matches all filetypes that don't have a formatter
        -- N.B. that this **WILL** attach to buffers that use the lsp_format fallback
        -- ["_"] = { "trim_newlines", "trim_whitespace" },
      },
      -- Set default options
      default_format_opts = {
        -- Use the LSP formatter if there is no explicit formatter for the buffer
        lsp_format = "fallback",
      },
      notify_on_error = true,
      -- Set up format-on-save
      format_on_save = function(bufnr)
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end
    })

    vim.api.nvim_create_user_command("FormatDisable", function(args)
      if args.bang then
        -- FormatDisable! will disable formatting just for this buffer
        vim.b.disable_autoformat = true
      else
        vim.g.disable_autoformat = true
      end
    end, {
      desc = "Disable autoformat-on-save",
      bang = true,
    })
    vim.api.nvim_create_user_command("FormatEnable", function()
      vim.b.disable_autoformat = false
      vim.g.disable_autoformat = false
    end, {
      desc = "Re-enable autoformat-on-save",
    })
  end,
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
