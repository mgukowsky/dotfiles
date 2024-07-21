local function install_dap_signs()
  vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "BreakpointSet", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "🛑", texthl = "", linehl = "BreakpointSet", numhl = "" })
  vim.fn.sign_define("DapLogPoint", { text = "🔶", texthl = "", linehl = "BreakpointSet", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "🟠", texthl = "", linehl = "debugPC", numhl = "" })
  vim.fn.sign_define("DapBreakpointRejected", { text = "🔘", texthl = "", linehl = "", numhl = "" })
end

local function setup_dap()
  install_dap_signs()

  local dap = require("dap")
  local dap_util = require("local.dap_util")
  dap.adapters = {
    -- vscode cpptools DAP, per
    -- https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(gdb-via--vscode-cpptools)
    cppdbg = {
      id = "cppdbg",
      type = "executable",
      command = dap_util.get_cpptools_path(),
    },
    -- Native GDB DAP; doesn't seem to be quite as good as the vscode cpptools
    gdb = {
      id = "gdb",
      type = "executable",
      command = dap_util.GDB_PATH,
      args = { "-i", "dap" },
    },
    lldb = {
      id = "lldb",
      type = "executable",
      command = dap_util.LLDB_PATH,
    },
    codelldb = {
      executable = {
        command = dap_util.CODELLDB_PATH,
        args = { "--port", "${port}" },
        -- On windows you may have to uncomment this:
        -- detached = false,
      },
      id = "codelldb",
      port = "${port}",
      type = "server",
    },
    -- We let nvim-dap-python handle this configuration
    -- python = {
    --   id = 'python',
    --   type = 'executable',
    --   command = '/tmp/venv/bin/python',
    --   args = { '-m', 'debugpy.adapter' },
    --   options = {
    --     source_filetype = 'python',
    --   },
    -- }
  }

  -- Better Json support for nvim-dap, per
  -- https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#dap
  require("dap.ext.vscode").json_decode = require("overseer.json").decode
  require("dap.ext.vscode").load_launchjs(nil, {
    -- N.B. that this will cause multiple "cppdbg: <cfg name>" entries to show up in the
    -- list of configurations
    cppdbg = { "c", "cpp", "rust" },
  })

  -- Per https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#ccrust-via-lldb-vscode
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          all_frames = true,
          all_references = true,
          highlight_new_as_changed = true,
          only_first_definition = false,
        }
      },
      {
        "stevearc/overseer.nvim",
        opts = {
          task_list = {
            default_detail = 2,
          },
        }
      },
    },
    keys = {
      {"<F5>", function() require("dap").continue() end, desc = "Continue (DAP)"},
      {"<F7>",
        function()
          local overseer = require("overseer")
          overseer.open()
          overseer.run_template()
        end, desc = "Run overseer template"},
      {"<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint"},
      {"<F10>", function() require("dap").step_over() end, desc = "Step over"},
      {"<F11>", function() require("dap").step_into() end, desc = "Step into"},
      -- This is the keysym for Shift+F11 (i.e. F12 + 11)
      {"<F23>", function() require("dap").step_out() end, desc = "Step out"},

      {"<leader>d", group = "Debugger (DAP)"},
      {"<leader>db", group = "Breakpoints"},
      {"<leader>dbb", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint"},

      -- Per https://www.reddit.com/r/neovim/comments/15dtb8l/comment/ju4u4j7
      -- Seems like variables can be referenced directly and don't need the {} wrapping
      --  e.g. `i > 5` is OK;
      {"<leader>dbc", function()
        vim.ui.input({ prompt = "Breakpoint condition" }, function(input)
          require("dap").set_breakpoint(input)
        end)
      end, desc = "Conditional breakpoint"},
      {"<leader>dbh", function()
        vim.ui.input({ prompt = "Hit condition (e.g. how many hits before stopping)" }, function(input)
          require("dap").set_breakpoint(nil, input)
        end)
      end, desc = "Hit conditional breakpoint"},

      -- Requires the {} dereferencing syntax
      --  e.g. `num is {num}` is necessary
      {"<leader>dbl", function()
        vim.ui.input({ prompt = "Trace log message" }, function(input)
          require("dap").set_breakpoint(nil, nil, input)
        end)
      end, desc = "Set breakpoint with log message"},

      {"<leader>dc", function() require("dap").continue() end, desc = "Start/Continue execution"},

      {"<leader>df", group = "Frames"},
      {"<leader>dfc", function() require("dap").focus_frame() end, desc = "Go to current (active) frame"},
      {"<leader>dfd", function() require("dap").down() end, desc = "Go down one frame"},
      {"<leader>dfr", function() require("dap").restart_frame() end, desc = "Restart execution of the current frame"},
      {"<leader>dfu", function() require("dap").up() end, desc = "Go up one frame"},

      {"<leader>dn", function() require("dap").step_over() end, desc = "Step Over"}, -- "next"
      {"<leader>do", function() require("dap").step_out() end, desc = "Step Out"}, -- "finish"
      {"<leader>dp", function() require("dap").pause() end, desc = "Pause execution"},
      {"<leader>ds", function() require("dap").step_into() end, desc = "Step Into"},
      {"<leader>du", function() require("dap").run_to_cursor() end, desc = "Run until current line"}, -- this will temporarily disable breakpoints
      {"<leader>dx", function() require("dap").terminate() end, desc = "Terminate running program"},

      {"<leader>dq", group = "DAP commands"},
      {"<leader>dqq", function() require("telescope").extensions.dap.commands() end, desc = "Command search"},
      {"<leader>dqb", function() require("telescope").extensions.dap.list_breakpoints() end, desc = "List breakpoints"},
      {"<leader>dqc", function() require("telescope").extensions.dap.configurations() end, desc = "Select configuration"},
      {"<leader>dqf", function() require("telescope").extensions.dap.frames() end, desc = "List frames"},
      {"<leader>dqv", function() require("telescope").extensions.dap.variables() end, desc = "List variables"},
    },
    config = function()
      install_dap_signs()
    end
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "nvim-neotest/nvim-nio" },
    keys = {
      {"<leader>dt", function() require("dapui").toggle() end, desc = "Toggle DAP UI"},
      {"<leader>d]", function() require("dapui").eval(nil, { enter = true }) end, desc = "Evaluate variable under cursor/highlight"},
    },
    config = function()
      setup_dap()

      local dapui = require("dapui")
      dapui.setup()

      -- Setup listeners to trigger/close the UI on debugging events
      local dap = require("dap")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end
  },
}
