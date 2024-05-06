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

  return toolspath .. '/debugAdapters/bin/OpenDebugAD7'
end

return M
