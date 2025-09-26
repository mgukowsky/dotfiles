local util = require("local.util")

local SECRET_CMD = "mg_get_secret"

local function get_api_key(keyname)
  local env_key = os.getenv(keyname)

  if env_key then
    return env_key
  elseif vim.fn.executable(SECRET_CMD) == 1 then
    return util.stdout_exec(SECRET_CMD .. " " .. keyname)
  else
    return nil
  end
end

return {
  "olimorris/codecompanion.nvim",
  config = function()
    local api_key = get_api_key("CLAUDE_API_KEY")

    if not api_key then
      vim.notify("AI functionality not available", vim.log.levels.WARN)
      return
    end

    require("codecompanion").setup({
      adapters = {
        acp = {
          claude_code = function()
            return require("codecompanion.adapters").extend("claude_code", {
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = api_key,
              },
            })
          end,
        },
        -- openai = function()
        --   return require("codecompanion.adapters").extend("openai", {
        --     env = {
        --       api_key = api_key,
        --     },
        --     schema = {
        --       model = {
        --         default = "gpt-4o",
        --       }
        --     }
        --   })
        -- end,
      },
      strategies = {
        chat = { adapter = "claude_code" },
        cmd = { adapter = "claude_code" },
        inline = { adapter = "claude_code" },
        workflow = { adapter = "claude_code" },
      }
    })
  end,
  keys = {
    { "<leader>ca", "<cmd>CodeCompanionActions<cr>",     desc = "Action picker" },
    { "<leader>cc", "<cmd>CodeCompanionChat toggle<cr>", desc = "Toggle chat" },
    { "<leader>ci", "<cmd>CodeCompanion<cr>",            mode = { "n", "v" },   desc = "Inline assistant" },
  }
}
