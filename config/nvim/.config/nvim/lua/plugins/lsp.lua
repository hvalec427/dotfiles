return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
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
    end,
  },
}
