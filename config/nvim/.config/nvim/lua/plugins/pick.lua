return {
  "nvim-mini/mini.pick",
  dependencies = { "nvim-mini/mini.extra", "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    require("mini.pick").setup()
    require("mini.extra").setup()

    -- Make the highlighted (current) row stand out more than the default
    -- CursorLine link. Re-apply on ColorScheme so mini's defaults don't win.
    local function set_pick_hl()
      vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", { link = "PmenuSel" })
    end
    set_pick_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_pick_hl })
  end,
}
