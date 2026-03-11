return {
  {
    "sainnhe/sonokai",
    lazy = false,
    priority = 1000,
    opts = {
      style = "andromeda",
      transparent_background = false,
      term_colors = true,
    },
    config = function(_, opts)
      vim.g.sonokai_style = opts.style
      vim.g.sonokai_transparent_background = opts.transparent_background and 1 or 0
      vim.g.sonokai_disable_terminal_colors = opts.term_colors and 0 or 1
      vim.cmd("colorscheme sonokai")
    end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
