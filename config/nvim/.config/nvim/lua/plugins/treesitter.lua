return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    local ok, ts = pcall(require, "nvim-treesitter")
    -- On a fresh install lazy may run `config` before the `main` branch is
    -- checked out; the old `master` module has no `install`. Bail quietly so
    -- we don't get "Failed to run config" -- a restart / :Lazy sync fixes it.
    if not ok or type(ts.install) ~= "function" then
      return
    end

    -- Needs the `tree-sitter` CLI to compile parsers (Brewfile: tree-sitter-cli).
    pcall(ts.install, {
      "lua", "vim", "vimdoc", "javascript", "typescript", "tsx",
      "json", "html", "css", "markdown", "markdown_inline",
    })

    -- The `main` branch no longer auto-enables highlighting; start it per
    -- buffer via FileType. Markdown stays disabled (as before).
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if vim.bo[args.buf].filetype == "markdown" then return end
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
