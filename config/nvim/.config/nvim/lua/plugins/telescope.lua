return {
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")

      -- Use fd if available, otherwise fallback to rg.
      -- Crucially: include hidden files/dirs (dotfolders) so .config/** shows up.
      local function find_command()
        if vim.fn.executable("fd") == 1 then
          return {
            "fd",
            "--type",
            "f",
            "--hidden",
            "--follow",
            "--exclude",
            ".git",
          }
        end

        return {
          "rg",
          "--files",
          "--hidden",
          "--follow",
          "--glob",
          "!.git/*",
        }
      end

      telescope.setup({
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
          file_ignore_patterns = { "%.DS_Store$", "%.DS_store$" },
        },

        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
            find_command = find_command(),
          },

          live_grep = {
            additional_args = function()
              return { "--hidden" }
            end,
          },
        },
      })
    end,
  },
}
