local SECRET_CMD = "mg_get_secret"

local function get_api_key_cmd()
  if vim.fn.executable(SECRET_CMD) == 1 then
    return SECRET_CMD .. " OPENAI_SECRET_KEY"
  else
    return nil
  end
end

local function setup_ai()
  local api_key_cmd = get_api_key_cmd()

  if not api_key_cmd and not os.getenv("OPENAI_API_KEY") then
    -- vim.notify("AI functionality not available", vim.log.levels.WARN)
    return
  end

  require("chatgpt").setup({
    api_key_cmd = api_key_cmd,
    chat = {
      answer_sign = "🤖",
    }
  })

  -- Recommended mappings
  local wk = require("which-key")
  wk.register({
    ["<leader>"] = {
      c = {
        name = "ChatGPT",
        a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
        c = { "<cmd>ChatGPTCompleteCode<CR>", "Complete code", mode = { "n", "v" } },
        d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
        e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
        f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
        g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
        k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
        l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
        o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
        p = { "<cmd>ChatGPTActAs<CR>", "Prompt selection" },
        q = { "<cmd>ChatGPT<CR>", "ChatGPT session" },
        r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
        s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
        t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
        x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
      },
    },
  })
end

setup_ai()
