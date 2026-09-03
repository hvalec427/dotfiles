return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").install({
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
