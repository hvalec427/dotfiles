return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      -- Native completion capabilities (replaces cmp_nvim_lsp).
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      -- Turn on Neovim's built-in LSP completion (auto-triggered) per buffer.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
          end
        end,
      })

      local mason_lspconfig = require("mason-lspconfig")

      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        ts_ls = {},
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
