return {
  "milanglacier/minuet-ai.nvim",
  event = "InsertEnter",
  main = "minuet",
  opts = {
    provider = "claude",
    provider_options = {
      claude = {
        model = "claude-haiku-4-5",
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
