return {
  "nvim-mini/mini.pick",
  dependencies = { "nvim-mini/mini.extra", "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    require("mini.pick").setup()
    require("mini.extra").setup()
  end,
}
