-- Language Server Protocol Configuration

-- Change the icon that precedes diagnostics, per
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-prefixcharacter-preceding-the-diagnostics-virtual-text

vim.diagnostic.config({
	virtual_text = {
		prefix = "🤯",
	},
})

-- Configuration for vim diagnostics; per
-- https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization#change-diagnostic-symbols-in-the-sign-column-gutter
local signs = { Error = "🤬", Warn = "😬", Hint = "🤔", Info = "🤓" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Recommended LSP configuration per https://github.com/neovim/nvim-lspconfig
local function on_attach(_, bufnr)
  local wk = require("which-key")
	-- Enable completion recommendations from the LSP
	vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })

	-- TODO: can/should these go in the opts file?
	vim.opt.completeopt:remove("preview") -- Don't show the stupid Scratch window

	-- EDIT: Disabled this as I found it to be too noisy
	-- This will trigger according to the interval set in `vim.opt.updatetime`
	-- TODO: consider power needs...
	if false then
		vim.api.nvim_create_autocmd("CursorHold", {
			buffer = bufnr,
			callback = function()
				-- Display any diagnostic(s) for the current line, otherwise show generic hover information
				local current_line = vim.api.nvim_win_get_cursor(0)[1]

				-- N.B. lnum starts at 0, so it will be one less than the current line
				if #(vim.diagnostic.get(bufnr, { lnum = current_line - 1 })) > 0 then
					vim.diagnostic.open_float({ noremap = true, silent = true })
				else
					vim.lsp.buf.hover()
				end
			end,
		})
	end

	-- Autoformat on save
	-- Per https://www.jvt.me/posts/2022/03/01/neovim-format-on-save/, but updated to use
	-- vim.lsp.buf.format instead of the deprecated (and removed) vim.lsp.buf.formatting_sync
	-- vim.api.nvim_create_autocmd("BufWritePre", {
	-- 	buffer = bufnr,
	-- 	callback = function()
	-- 		vim.lsp.buf.format({ bufnr = bufnr, async = false })
	-- 	end,
	-- })

	--[[
  -- Create a custom popup menu for various LSP-based actions we can take. I prefer this to
  -- having to create and memorize a shortcut for each of these, most of which I will rarely use
  --]]
	local LSPMenu = "]LSPMenu" -- The leading ']' is a vim-ism for "hidden" menus like this one

	-- Some commands are in the vim.lsp.buf namespace, and some are in the telescope namespace
	local LSP = 0 -- Identifier for LSP functions
	local TEL = 1 -- Identifier for Telescope functions
	local SAGA = 2 -- Identifiers for Lspsaga
	local SAGAREF = 3
	local SAGAIMP = 4

	local function add_menu_entry(entry)
		local namespace = entry[1]
		local methodname = entry[2]

		local cmdstring

		if namespace == LSP then
			cmdstring = ":lua vim.lsp.buf."
				.. string.lower(methodname)
				.. "({noremap=true, silent=true, buffer="
				.. bufnr
				.. "})<cr>"
		elseif namespace == TEL then
			cmdstring = ":lua require('telescope.builtin').lsp_" .. string.lower(methodname) .. "()<cr>"
		elseif namespace == SAGA then
			cmdstring = ":Lspsaga " .. string.lower(methodname) .. "<cr>"
		elseif namespace == SAGAREF then
			cmdstring = ":Lspsaga finder ref<cr>"
		elseif namespace == SAGAIMP then
			cmdstring = ":Lspsaga finder imp<cr>"
		end

		vim.cmd.amenu({
			LSPMenu .. "." .. methodname,
			-- TODO: can we provide a lua function as the callback instead of the vim cmd string?
			cmdstring,
		})
		-- TODO: Use vim.cmd.tmenu to add a tooltip for each entry
	end

	local SEP = "Sep" -- Arbitrary string to represent a menu separator
	local numSep = 1 -- Each separator must have a unique identifier
	for _, entry in pairs({
		-- General info
		{ SAGA, "Hover_Doc" },
		{ SAGA, "Outline" },
		{ TEL, "Definitions" },
		{ SAGA, "Show_Workspace_Diagnostics" },
		{ LSP, "Declaration" },
		{ SAGAIMP, "Implementations" },
		{ TEL, "Type_Definitions" },
		{ LSP, "TypeHierarchy" },
		{ SAGA, "Peek_Type_Definition" },
		SEP,
		-- Code structure info
		{ SAGAREF, "References" },
		{ SAGA, "Incoming_Calls" },
		{ SAGA, "Outgoing_Calls" },
		{ TEL, "Document_Symbols" },
		{ TEL, "Workspace_Symbols" },
		SEP,
		-- Refactoring actions
		{ SAGA, "Code_Action" },
		{ LSP, "Rename" },
		{ LSP, "Signature_Help" },
	}) do
		if entry == SEP then
			-- In order to be parsed as a separator, the identifier must be surrounded by -minuses-
			-- The command cannot be empty and must have something other than just whitespace,
			-- so we give it a no-op
			vim.cmd.amenu({ LSPMenu .. ".-" .. SEP .. numSep .. "-", "echo ''" })
			numSep = numSep + 1
		else
			add_menu_entry(entry)
		end
	end

	-- I like this mapping, since C-] will be set to peek definition, and this
	-- <leader> version can be used for all other less-frequently-used options
	vim.keymap.set("n", "<C-]>", "<cmd>Lspsaga peek_definition<cr>", {desc = "Peek definition"})
	wk.register({
		["<leader>"] = {
			["]"] = {
				function() vim.cmd.popup(LSPMenu) end,
				"LSP Popup menu",
			},
			n = {
				function() vim.cmd("Lspsaga outline") end,
				"Toggle LSP code outline",
			},
			l = {
				{
					name = "LSP functions",
					a = {
						function() vim.cmd("Lspsaga code_action") end,
						"LSP code action",
					},
					d = {
						function() require("telescope.builtin").diagnostics({ bufnr = 0 }) end,
						"Diagnostics",
					},
					i = {
						function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end,
						"Toggle Inlay Hints",
					},
					s = {
						function() require("telescope.builtin").lsp_document_symbols() end,
						"Document Symbol search",
					},
					w = {
						function() require("telescope.builtin").lsp_workspace_symbols() end,
						"Workspace Symbol search",
					},
				},
			},
		},
		["+"] = {
			function() vim.cmd("Lspsaga hover_doc") end,
			"Show hover (press twice to focus)",
		},
	}, {
		buffer = bufnr,
	})

	-- Movement mappings
	local next_diag_repeat, prev_diag_repeat = require("nvim-treesitter.textobjects.repeatable_move").make_repeatable_move_pair(function()
		require("lspsaga.diagnostic"):goto_next()
	end, function()
		require("lspsaga.diagnostic"):goto_prev()
	end)
	wk.register({
		["["] = {
			d = {
				function() prev_diag_repeat() end,
				"Prev LSP diagnostic",
			},
		},
		["]"] = {
			d = {
				function() next_diag_repeat() end,
				"Next LSP diagnostic",
			},
		},
	}, {
		mode = { "n", "x", "o" },
	})
end

local function get_lsp_caps()
  -- nvim-cmp; needs to be set as the "capabilities for each lsp"
  return require("cmp_nvim_lsp").default_capabilities()
end

local function setup_lsps()
  -- From nvim-lspconfig plugin
  local lspconfigs = require("lspconfig")

  lspconfigs.lua_ls.setup({
    on_attach = on_attach,
    capabilities = get_lsp_caps(),
    settings = {
      Lua = {
        runtime = { version = "LuaJIT" },
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  })
end

return {
  "neovim/nvim-lspconfig",
  config = function()
    setup_lsps()
  end,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "folke/which-key.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-telescope/telescope.nvim",
    "hrsh7th/cmp-nvim-lsp",
    {
      "nvimdev/lspsaga.nvim",
      opts = {
        callhierarchy = {
          keys = {
            edit = "<CR>",
            toggle_or_req = "<Space>",
          },
        },
        code_action = {
          extend_gitsigns = true,
          num_shortcut = true,
          show_server_name = true,
        },
        definition = {
          width = 0.8,
          height = 0.5,
          keys = {
            edit = "<CR>",
          },
        },
        diagnostic = {
          extend_relatedInformation = true,
        },
        finder = {
          keys = {
            toggle_or_open = "<CR>",
          },
          max_height = 0.8,
        },
        implement = {
          enable = true,
          sign = true,
        },
        lightbulb = {
          debounce = 3000, -- lightbulb can be noisy and/or cause performance issues, so let's throttle it
        },
        outline = {
          close_after_jump = false,
          layout = "float",
          keys = {
            toggle_or_jump = "<CR>",
          },
          max_height = 0.8,
          win_width = 45,
        },
        symbol_in_winbar = {
          enable = true,
        },
        ui = {
          border = "rounded",
        },
      },
    }
  }
}
