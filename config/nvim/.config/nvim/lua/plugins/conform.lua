return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  config = function()
    require("conform").setup({
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier", "eslint_d" },
        typescript = { "prettier", "eslint_d" },
        svelte = { "prettier" },
        -- No Python formatter installed; just clean up whitespace.
        python = { "trim_whitespace", "trim_newlines" },
      },
    })
  end,
}
