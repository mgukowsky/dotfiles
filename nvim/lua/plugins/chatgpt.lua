local SECRET_CMD = "mg_get_secret"

local function get_api_key_cmd()
  if vim.fn.executable(SECRET_CMD) == 1 then
    return SECRET_CMD .. " OPENAI_SECRET_KEY"
  else
    return nil
  end
end

return {
  "jackMort/ChatGPT.nvim",
  config = function()
    local api_key_cmd = get_api_key_cmd()

    if not api_key_cmd and not os.getenv("OPENAI_API_KEY") then
      -- vim.notify("AI functionality not available", vim.log.levels.WARN)
      return
    end

    require("chatgpt").setup({
      api_key_cmd = api_key_cmd,
      chat = {
        -- answer_sign = "🤖",
      },
    })
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim",
    "nvim-telescope/telescope.nvim"
  },
  keys = {
    {"<leader>ca", "<cmd>ChatGPTRun add_tests<CR>", desc = "Add Tests", mode = { "n", "v" }},
    {"<leader>cc", "<cmd>ChatGPTCompleteCode<CR>", desc = "Complete code", mode = { "n", "v" }},
    {"<leader>cd", "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring", mode = { "n", "v" }},
    {"<leader>ce", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction", mode = { "n", "v" }},
    {"<leader>cf", "<cmd>ChatGPTRun fix_bugs<CR>", desc = "Fix Bugs", mode = { "n", "v" }},
    {"<leader>cg", "<cmd>ChatGPTRun grammar_correction<CR>", desc = "Grammar Correction", mode = { "n", "v" }},
    {"<leader>ck", "<cmd>ChatGPTRun keywords<CR>", desc = "Keywords", mode = { "n", "v" }},
    {"<leader>cl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis", mode = { "n", "v" }},
    {"<leader>co", "<cmd>ChatGPTRun optimize_code<CR>", desc = "Optimize Code", mode = { "n", "v" }},
    {"<leader>cp", "<cmd>ChatGPTActAs<CR>", desc = "Prompt selection", mode = "n" },
    {"<leader>cq", "<cmd>ChatGPT<CR>", desc = "ChatGPT session", mode = "n" },
    {"<leader>cr", "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit", mode = { "n", "v" }},
    {"<leader>cs", "<cmd>ChatGPTRun summarize<CR>", desc = "Summarize", mode = { "n", "v" }},
    {"<leader>ct", "<cmd>ChatGPTRun translate<CR>", desc = "Translate", mode = { "n", "v" }},
    {"<leader>cx", "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code", mode = { "n", "v" }},
  }
}
