return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    config = function()
      -- Advertise blink.cmp's completion capabilities to every server so the
      -- menu gets rich items (auto-imports, snippets, additionalTextEdits).
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local mason_lspconfig = require("mason-lspconfig")

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        -- vtsls instead of ts_ls: its auto-import/un-imported completions are
        -- far more reliable, so custom (not-yet-imported) React components
        -- actually show up in the blink menu.
        vtsls = {
          settings = {
            typescript = {
              -- Offer un-imported symbols as auto-import candidates.
              suggest = { completeFunctionCalls = true },
              -- Style of the import written when a candidate is accepted.
              preferences = {
                importModuleSpecifierPreference = "shortest",
              },
            },
            javascript = {
              suggest = { completeFunctionCalls = true },
              preferences = {
                importModuleSpecifierPreference = "shortest",
              },
            },
          },
        },
        eslint = {},
        graphql = {
          filetypes = {
            "graphql",
            "gql",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
          },
        },
      }
      for server_name in pairs(servers) do
        local server_opts = vim.tbl_deep_extend(
          "force",
          { capabilities = capabilities },
          servers[server_name] or {}
        )
        vim.lsp.config(server_name, server_opts)
      end

      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- vim.lsp.config() only registers config; enable() actually starts the servers
      vim.lsp.enable(vim.tbl_keys(servers))
    end,
  },
}
