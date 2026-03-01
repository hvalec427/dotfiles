return { {
  "sainnhe/sonokai",
  lazy = false,
  priority = 1000,
  opts = {
    contrast = "medium",
    background = "dark",
    italic = true,
    underline = true,
  },
  config = function()
    vim.g.gruvbox_material_background = "medium"
    vim.g.gruvbox_material_foreground = "material"
    vim.g.gruvbox_material_better_performance = 1
    vim.cmd("colorscheme sonokai")
  end,
},
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
