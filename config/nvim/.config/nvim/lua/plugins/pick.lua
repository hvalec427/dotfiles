return {
  "nvim-mini/mini.pick",
  dependencies = { "nvim-mini/mini.extra", "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    -- Center the picker as a floating window (mini.pick defaults to a
    -- bottom-anchored, full-width strip).
    local function centered_win()
      local width = math.floor(vim.o.columns * 0.8)
      local height = math.floor(vim.o.lines * 0.8)
      return {
        relative = "editor",
        anchor = "NW",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = "rounded",
      }
    end

    require("mini.pick").setup({
      window = { config = centered_win },
    })
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
