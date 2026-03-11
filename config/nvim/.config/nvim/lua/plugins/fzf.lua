return {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      keymap = {
        fzf = {
          ["tab"] = "ignore",
          ["btab"] = "ignore", -- shift+tab
        },
      },
    },
  },
}
