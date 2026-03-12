return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      keymap = {
        fzf = {
          ["tab"] = "down",
          ["btab"] = "up",
        },
      },
    },
  },
}
