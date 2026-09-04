return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    -- Close oil, but if there are unsaved edits ask to Save / Discard / Cancel.
    local function close_with_prompt()
      local close = function() require("oil.actions").close.callback() end
      if not vim.bo.modified then
        close()
        return
      end
      local choice = vim.fn.confirm("You have unsaved changes.", "&Save\n&Discard\n&Cancel", 3)
      if choice == 1 then -- Save
        require("oil").save({ confirm = false }, function(err)
          if not err or err == "Canceled" then
            vim.schedule(close)
          end
        end)
      elseif choice == 2 then -- Discard
        -- Floating oil only closes the window, keeping the buffer (and its
        -- pending mutations) alive, so reset it to the on-disk state first.
        require("oil").discard_all_changes()
        close()
      end
      -- choice == 3 or 0 (Cancel): stay in oil
    end

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
        ["q"] = close_with_prompt,
        ["<Esc>"] = close_with_prompt,
      },
    })
  end,
}
