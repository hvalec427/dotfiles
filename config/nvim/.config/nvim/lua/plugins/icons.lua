return {
  "nvim-mini/mini.icons",
  version = false,
  lazy = false,
  priority = 900,
  config = function()
    local icons = require("mini.icons")
    icons.setup()
    -- Let plugins that still `require("nvim-web-devicons")` (lualine, oil,
    -- fff, ...) transparently use mini.icons instead.
    icons.mock_nvim_web_devicons()
  end,
}
