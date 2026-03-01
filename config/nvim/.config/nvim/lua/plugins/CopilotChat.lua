return {
  "CopilotC-Nvim/CopilotChat.nvim",
  dependencies = {
    "github/copilot.vim",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
  },
  config = function()
    require("CopilotChat").setup({
      auto_insert_mode = true,
    })
  end,
}
