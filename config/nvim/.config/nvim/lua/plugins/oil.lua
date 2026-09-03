return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    require("oil").setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 2,
        max_width = 100,
        max_height = 30,
        border = "rounded",
      },
      keymaps = {
        ["q"] = "actions.close",
        ["<Esc>"] = "actions.close",
      },
    })
  end,
}
