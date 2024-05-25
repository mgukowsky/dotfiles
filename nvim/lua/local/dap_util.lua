local M = {}

M.GDB_PATH = '/usr/bin/gdb'
M.LLDB_PATH = '/usr/bin/lldb-vscode'
M.CODELLDB_PATH = '/usr/sbin/codelldb'

-- Find the most recently installed cpptools vscode plugin's DAP binary,
-- or nil if not installed
function M.get_cpptools_path()
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

  local fullpath = toolspath .. '/debugAdapters/bin/OpenDebugAD7'

  -- Sometimes the DAP binary will be installed with the wrong perms
  if vim.fn.executable(fullpath) ~= 1 then
    vim.notify("Debug adapter is not executable: " .. fullpath, vim.log.levels.ERROR)
    return nil
  end

  return fullpath
end

-- Create a DAP session using the first DAP adapter found in the list [cpptools, codelldb, lldb,
-- gdb]
function M.run_dap_config(program_path, program_name, args)
  local cfg = {
    cwd = "${workspaceFolder}",
    name = "Launch",
    program = program_path,
    args = args,
    request = "launch",
    stopAtEntry = false,
  }

  -- tasks.json must exist in order for us to use a task from it
  if vim.fn.filereadable("./.vscode/tasks.json") == 1 then
    cfg.preLaunchTask = "default_build"
  end

  local cpptools_path = M.get_cpptools_path()

  if cpptools_path ~= nil and vim.fn.executable(cpptools_path) then
    cfg.type = "cppdbg"
    cfg.linux = {
      MIMode = "gdb",
      miDebuggerPath = "/usr/bin/gdb"
    }
    cfg.osx = {
      MIMode = "lldb",
      miDebuggerPath = "/usr/local/bin/lldb-mi"
    }
    cfg.windows = {
      MIMode = "gdb",
      miDebuggerPath = "C:\\MinGw\\bin\\gdb.exe"
    }
    cfg.setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false
      }
    }
  elseif vim.fn.executable(M.CODELLDB_PATH) then
    cfg.type = "codelldb"
  elseif vim.fn.executable(M.LLDB_PATH) then
    cfg.type = "lldb"
  elseif vim.fn.executable(M.GDB_PATH) then
    cfg.type = "gdb"
    cfg.setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "enable pretty printing",
        ignoreFailures = false
      }
    }
  else
    vim.notify("No executable DAP binary found", vim.log.levels.ERROR)
    return
  end

  vim.notify("Running " .. program_name .. " via " .. cfg.type)
  require("dap").run(cfg)
end

return M
