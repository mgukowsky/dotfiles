local M = {}

-- Invoke a callback if compile_commands.json is present, otherwise show an error
function M.run_if_compile_commands(fn)
  if vim.fn.filereadable("compile_commands.json") == 0 then
    vim.notify("compile_commands.json not present in working directory")
  else
    fn()
  end
end

-- Run a program to completion, and return its stdout as a string, or "" if something goes wrong
function M.stdout_exec(cmd)
  local handle = io.popen(cmd)
  if handle ~= nil then
    local output = handle:read("*a")
    handle:close()
    return vim.trim(output)
  else
    return ""
  end
end

return M
