-- Tracks file visits so `ff` can rank frequently/recently used files first and
-- `fv` can list only visited files. Loaded at startup so every visit counts.
return {
  "nvim-mini/mini.visits",
  lazy = false,
  config = function()
    require("mini.visits").setup()
  end,
}
