return {
  "nvim-mini/mini.pick",
  dependencies = { "nvim-mini/mini.extra", "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    local preview = require("pick_preview")

    -- Squeeze the picker into a centered left pane; pick_preview draws a live
    -- preview float in the matching right pane (see lua/pick_preview.lua).
    require("mini.pick").setup({
      window = { config = preview.win_config },
      mappings = {
        toggle_all = { char = "<M-m>", func = function() require("pickers").toggle_all() end },
        -- Scroll the side preview float (C-n/C-p already move the selection).
        preview_down = { char = "<C-j>", func = function() require("pick_preview").scroll(1) end },
        preview_up = { char = "<C-k>", func = function() require("pick_preview").scroll(-1) end },
      },
    })
    require("mini.extra").setup()
    preview.setup()

    -- Make the highlighted (current) row stand out more than the default
    -- CursorLine link. Re-apply on ColorScheme so mini's defaults don't win.
    local function set_pick_hl()
      vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { link = "PmenuSel" })
    end
    set_pick_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_pick_hl })
  end,
}
