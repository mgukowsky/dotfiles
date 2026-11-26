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

-- Build an operator (for use with `g@`) which passes the text covered by a motion to `fn`.
-- The returned function must be mapped with `expr = true`.
function M.text_operator(fn)
  return function()
    -- 'operatorfunc' is a string option, so it can't hold a Lua closure directly; it must be a global that Vimscript can
    -- reach via `v:lua`. It's reassigned on every invocation so the active operator's `fn` is the one that gets called.
    _G.__text_opfunc = function(motion_type)
      -- `g@` passes the motion type as "char", "line", or "block"; getregion() wants the equivalent visual mode
      -- ("\22" is <C-v>, i.e. blockwise)
      local regtype = ({ char = "v", line = "V", block = "\22" })[motion_type]
      -- `g@` sets the '[ and '] marks to the start/end of the motion (or visual selection); fetch the text between them
      local lines = vim.fn.getregion(vim.fn.getpos("'["), vim.fn.getpos("']"), { type = regtype })
      -- grep tools match line-by-line, so collapse multi-line selections into a single line
      local text = vim.trim(table.concat(lines, " "))
      fn(text)
    end
    -- `v:lua.<name>` tells Vim to call the global Lua function `<name>` when `g@` fires.
    -- Clobbering this global option is safe and idiomatic (see `:h g@`).
    vim.o.operatorfunc = "v:lua.__text_opfunc"
    -- `g@` is Vim's "call 'operatorfunc'" operator: it waits for a motion (or uses the visual selection), then calls it
    return "g@"
  end
end

return M
