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

      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = { diagnostics = { globals = { "vim" } } },
        },
      })

      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls" },
        automatic_enable = false,
      })

      vim.lsp.enable("lua_ls")
      vim.lsp.enable("ts_ls")
    end,
  },
}
