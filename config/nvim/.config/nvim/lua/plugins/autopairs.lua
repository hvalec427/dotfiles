return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  dependencies = { "nvim-cmp" },
  config = function()
    local autopairs = require("nvim-autopairs")
    local cmp_autopairs = require("nvim-autopairs.completion.cmp")

    autopairs.setup({
      check_ts = true,
      disable_filetype = { "fzf", "vim" },
      fast_wrap = {},
    })

    local cmp = require("cmp")

    cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ map_char = { all = "" } }))
  end,
}
