-- LuaJit profiler. Not that great, but better than nothing

MGPROF_PROFILER_ACTIVE = false
MGPROF_PROFILE_ID = ""
MGPROF_PROFILE_PATH = "/tmp/nvimprof"

vim.keymap.set("n", "<leader>qp",
  function()
    if MGPROF_PROFILER_ACTIVE then
      require("jit.p").stop()

      vim.notify("Profiler stopped; output written to:\n" .. MGPROF_PROFILE_PATH .. MGPROF_PROFILE_ID)
    else
      MGPROF_PROFILE_ID = vim.fn.strftime("%d-%m-%y-%H-%M-%S")
      vim.notify("Starting profiler...")

      -- First argument is the flags, second is the output
      -- Documented at https://luajit.org/ext_profiler.html
      require("jit.p").start("4sai1m1", MGPROF_PROFILE_PATH .. MGPROF_PROFILE_ID)
    end

    MGPROF_PROFILER_ACTIVE = not MGPROF_PROFILER_ACTIVE
  end, { desc = "Toggle profiler" })
