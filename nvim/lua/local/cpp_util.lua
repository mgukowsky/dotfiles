local M = {}

local util = require("local.util")
local dap_util = require("local.dap_util")

-- Get the name of the TEST(), TEST_F() or TEST_P() closest to the cursor.
-- Returns the suite and the name of the test (the first and second arguments to the macros,
-- respectively).
--
-- If not inside a TEST* macro, returns nil
local function get_cursor_gtest_info()
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

-- Returns the build directory by resolving compile_commands.json
-- Assumes that compile_commands.json exists
local function get_outdir()
  return util.stdout_exec("dirname $(realpath compile_commands.json)")
end

function M.dbg_select()
  local outdir = get_outdir()
  -- Get the paths of all executable targets relative to the root of the build directory
  local executables = vim.split(
    util.stdout_exec("ninja -C " .. outdir .. " -t targets all | grep -e 'EXECUTABLE' | cut -d':' -f1"), "\n")

  vim.ui.select(executables,
    { prompt = "Executable to debug:", format_item = function(item) return item end },
    function(choice)
      if choice ~= nil then
        dap_util.run_dap_config(outdir .. "/" .. choice, choice)
      end
    end)
end

function M.run_gtest_at_cursor()
  local info = get_cursor_gtest_info()

  if info == nil then
    vim.notify("Not in a TEST* body", vim.log.levels.ERROR)
    return
  end

  local outdir = get_outdir()
  -- ctest can provide us a nice manifest of all the tests mapped to their executables, in JSON format
  local ctest_json = require("dap.ext.vscode").json_decode(
    util.stdout_exec("cd " .. outdir .. " && ctest --show-only=json-v1"))

  local testname = info.suite .. "." .. info.test
  for _, testinfo in ipairs(ctest_json.tests) do
    if testinfo.name == testname then
      local executable = table.remove(testinfo.command, 1)
      dap_util.run_dap_config(executable, testname, testinfo.command)
      return
    end
  end

  vim.notify("Failed to find test config for " .. testname, vim.log.levels.ERROR)
end

return M
