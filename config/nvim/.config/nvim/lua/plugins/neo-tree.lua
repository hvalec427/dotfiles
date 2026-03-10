return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    lazy = false,
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        default_component_configs = {
          container = {
            enable_character_fade = true,
          },
          indent = {
            padding = 1,
            indent_size = 2,
            with_markers = true,
          },
        },
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = true,
            hide_by_name = { ".DS_Store", ".DS_store", "thumbs.db" },
          },
          follow_current_file = true,
          hijack_netrw_behavior = "open_default",
        },
        window = {
          position = "left",
          width = 35,
          mapping_options = {
            noremap = true,
            nowait = true,
          },
        },
      })
    end,
  },
}
