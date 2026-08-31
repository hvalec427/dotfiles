return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
        "json", "html", "css",
      },
      highlight = { enable = true, disable = { "markdown" } },
      indent = { enable = true },
    })
  end,
}
