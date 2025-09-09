local M = {}

-- Find the most recently installed cpptools vscode plugin's DAP binary,
-- or nil if not installed
function M.get_cpptools_path()
  -- First, we may just have the AUR repo available.
  local aurpath = "/usr/share/cpptools-debug/bin/OpenDebugAD7"
  if vim.fn.executable(aurpath) then
    return aurpath
  end

  local cpptools = vim.fn.glob("~/.vscode/extensions/ms-vscode.cpptools*")

  local max = nil
  local toolspath = nil
  for entry in cpptools:gmatch("[^\r\n]+") do -- glob() returns a string, so we need to split it
    local ftime = vim.fn.getftime(entry)
    if max == nil or ftime > max then
      toolspath = entry
      max = ftime
    end
  end

  if toolspath == nil then
    return nil
  end

  local fullpath = toolspath .. "/debugAdapters/bin/OpenDebugAD7"

  -- Sometimes the DAP binary will be installed with the wrong perms
  if vim.fn.executable(fullpath) ~= 1 then
    vim.notify("Debug adapter is not executable: " .. fullpath, vim.log.levels.ERROR)
    return nil
  end

  return fullpath
end

-- Creates a list of DAP configurations in the order [cpptools, codelldb, lldb, gdb]. Any entries
-- for which a corresponding binary cannot be found are omitted from the list.
local function make_cpp_configs()
  local cfgs = {}
  local basecfg = {
    cwd = "${workspaceFolder}",
    name = "Launch",
    request = "launch",
    stopAtEntry = false,
  }
  -- tasks.json must exist in order for us to use a task from it
  if vim.fn.filereadable("./.vscode/tasks.json") == 1 then
    basecfg.preLaunchTask = "default_build"
  end

  local cpptools_path = M.get_cpptools_path()

  if cpptools_path ~= nil and vim.fn.executable(cpptools_path) == 1 then
    local cfg = vim.deepcopy(basecfg)
    cfg.type = "cppdbg"
    cfg.linux = {
      MIMode = "gdb",
      miDebuggerPath = "gdb",
    }
    cfg.osx = {
      MIMode = "lldb",
      miDebuggerPath = "/usr/local/bin/lldb-mi",
    }
    cfg.windows = {
      MIMode = "gdb",
      miDebuggerPath = "C:\\MinGw\\bin\\gdb.exe",
    }
    cfg.setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false,
      },
    }
    table.insert(cfgs, cfg)
  elseif vim.fn.executable("codelldb") == 1 then
    local cfg = vim.deepcopy(basecfg)
    cfg.type = "codelldb"
    table.insert(cfgs, cfg)
  elseif vim.fn.executable("lldb-vscode") == 1 or vim.fn.executable("lldb") == 1 then
    local cfg = vim.deepcopy(basecfg)
    cfg.type = "lldb"
    table.insert(cfgs, cfg)
  elseif vim.fn.executable("gdb") == 1 then
    local cfg = vim.deepcopy(basecfg)
    cfg.type = "gdb"
    cfg.setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false,
      },
    }
    table.insert(cfgs, cfg)
  end

  return cfgs
end

M.CPP_CFGS = make_cpp_configs()

-- Create a DAP session using the first DAP adapter found in M.CPP_CFGS
function M.run_dap_config(program_path, program_name, args)
  if #M.CPP_CFGS < 1 then
    vim.notify("No executable DAP binary found", vim.log.levels.ERROR)
    return
  end
  local cfg = vim.deepcopy(M.CPP_CFGS[1])
  cfg.program = program_path
  cfg.args = args

  vim.notify("Running " .. program_name .. " via " .. cfg.type)
  require("dap").run(cfg)
end

return M
