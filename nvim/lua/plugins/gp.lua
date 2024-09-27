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
  "robitx/gp.nvim",
  config = function()
    local api_key = get_api_key()

    if not api_key then
      vim.notify("AI functionality not available", vim.log.levels.WARN)
    end

    require("gp").setup({
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1/chat/completions",
          secret = api_key
        },
      },
    })
  end,
  keys = {
    { "<leader>ca", "<cmd>GpAppend<cr>",           desc = "Append text" },
    { "<leader>ca", ":<C-u>'<,'>GpAppend<cr>",     mode = "v",                      desc = "Append text" },
    { "<leader>cd", "<cmd>GpChatDelete<cr>",       desc = "Delete chat" },
    { "<leader>cf", "<cmd>GpChatFinder<cr>",       desc = "Find chat" },
    { "<leader>ci", "<cmd>GpImplement<cr>",        desc = "Implement specification" },
    { "<leader>ci", ":<C-u>'<,'>GpImplement<cr>",  mode = "v",                      desc = "Implement specification" },
    { "<leader>cn", "<cmd>GpChatNew popup<cr>",    desc = "New chat" },
    { "<leader>cp", "<cmd>GpPrepend<cr>",          desc = "Prepend text" },
    { "<leader>cp", ":<C-u>'<,'>GpPrepend<cr>",    mode = "v",                      desc = "Prepend text" },
    { "<leader>cr", "<cmd>GpRewrite<cr>",          desc = "Rewrite" },
    { "<leader>cr", ":<C-u>'<,'>GpRewrite<cr>",    mode = "v",                      desc = "Rewrite" },
    { "<leader>ct", "<cmd>GpChatToggle popup<cr>", desc = "Toggle chat" },
  }
}
