local util = require("local.util")

local SECRET_CMD = "mg_get_secret"

local function get_api_key()
  local env_key = os.getenv("OPENAI_API_KEY")

  if env_key then
    return env_key
  elseif vim.fn.executable(SECRET_CMD) == 1 then
    return util.stdout_exec(SECRET_CMD .. " OPENAI_API_KEY")
  else
    return nil
  end
end

return {
  "olimorris/codecompanion.nvim",
  config = function()
    local api_key = get_api_key()

    if not api_key then
      vim.notify("AI functionality not available", vim.log.levels.WARN)
      return
    end

    require("codecompanion").setup({
      adapters = {
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = api_key,
            },
            schema = {
              model = {
                default = "gpt-4o",
              }
            }
          })
        end,
      },
      strategies = {
        chat = { adapter = "openai" },
        cmd = { adapter = "openai" },
        inline = { adapter = "openai" },
        workflow = { adapter = "openai" },
      }
    })
  end,
  keys = {
    { "<leader>cc", "<cmd>CodeCompanion toggle<cr>", desc = "Toggle chat" },
  }
}
