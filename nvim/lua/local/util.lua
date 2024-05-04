local M = {}

-- Get the name of the TEST(), TEST_F() or TEST_P() closest to the cursor.
-- Returns the suite and the name of the test (the first and second arguments to the macros,
-- respectively).
--
-- If not inside a TEST* macro, returns nil
function M.get_cursor_gtest_info()
  local ROOT_ID = vim.treesitter.get_parser():trees()[1]:root():id()
  local current_node = vim.treesitter.get_node()

  -- Recurse outwards until we find TEST* definition node, stopping if we hit the root
  while true do
    if vim.treesitter.get_node_text(current_node, 0):match("^TEST") and current_node:type() == "function_definition" then
      -- Since the TEST* macros all have the same signature and are always called in the same way,
      -- we can make assumptions about where the suite & name nodes will be.
      local suite_name = vim.treesitter.get_node_text(current_node:child(0):child(1):child(1), 0)
      local test_name = vim.treesitter.get_node_text(current_node:child(0):child(1):child(3), 0)
      return { suite = suite_name, test = test_name }
    end

    if current_node:id() == ROOT_ID then
      return nil
    end

    current_node = current_node:parent()
  end
end

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
