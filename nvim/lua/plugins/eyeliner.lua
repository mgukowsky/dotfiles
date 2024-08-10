-- Highlight characters after pressing f|F|t|T
return {
  "jinh0/eyeliner.nvim",
  event = "VeryLazy",
  opts = {
    highlight_on_key = true, -- Only highlight characters after pressing f|F|t|T
    dim = true, -- Dim all charcters that can't be jumped to
  }
}
