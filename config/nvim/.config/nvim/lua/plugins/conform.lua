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
        python = { "farm_tabs", "trim_whitespace", "trim_newlines" },
      },
      formatters = {
        -- The Farmer Was Replaced only accepts tab indentation.
        farm_tabs = {
          condition = function(_, ctx)
            return ctx.filename:find("TheFarmerWasReplaced", 1, true) ~= nil
          end,
          format = function(_, _, lines, callback)
            local out = vim.tbl_map(function(line)
              local indent = line:match("^%s*")
              local tabs = math.floor(vim.fn.strdisplaywidth(indent) / 4)
              return string.rep("\t", tabs) .. line:sub(#indent + 1)
            end, lines)
            callback(nil, out)
          end,
        },
      },
    })
  end,
}
