return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  dependencies = { "MeanderingProgrammer/treesitter-modules.nvim" },
  config = function()
    -- treesitter-modules restores the classic master-branch modules
    -- (install + highlight + indent) on top of the main branch, so we don't
    -- hand-roll the FileType/vim.treesitter.start wiring. pcall-guarded so a
    -- fresh install (main branch not checked out yet) doesn't hard-fail.
    pcall(function()
      require("treesitter-modules").setup({
        -- Needs the `tree-sitter` CLI to compile (Brewfile: tree-sitter-cli).
        ensure_installed = {
          "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
          "json", "html", "css", "markdown", "markdown_inline",
        },
        highlight = {
          enable = true,
          disable = { "markdown" }, -- keep markdown highlighting off, as before
        },
        indent = { enable = true },
      })
    end)
  end,
}
