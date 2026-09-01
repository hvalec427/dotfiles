return {
  "milanglacier/minuet-ai.nvim",
  event = { "BufReadPre", "BufNewFile" },
  main = "minuet",
  opts = {
    provider = "claude",
    provider_options = {
      claude = {
        model = "claude-haiku-4-5",
        api_key = function()
          return vim.trim(vim.fn.system({
            "security", "find-generic-password",
            "-a", vim.env.USER, "-s", "ANTHROPIC_API_KEY", "-w",
          }))
        end,
      },
    },
    virtualtext = {
      auto_trigger_ft = { "*" },
      auto_trigger_ignore_ft = { "help", "gitcommit", "gitrebase", "TelescopePrompt" },
      keymap = {
        accept = "<A-A>",
        accept_line = "<A-a>",
        accept_n_lines = "<A-z>",
        prev = "<A-[>",
        next = "<A-]>",
        dismiss = "<A-e>",
      },
    },
  },
}
