return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "gruvbox-material",
        section_separators = "",
        component_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {},
        lualine_x = {
          "encoding",
          { "filetype", icon_only = true },
          { "filename", path = 1 },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}

