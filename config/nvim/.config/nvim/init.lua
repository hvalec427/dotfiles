-- =========================
-- Basic Options
-- =========================
vim.g.mapleader = " "             -- Space as leader
vim.opt.clipboard = "unnamedplus" -- System clipboard
vim.opt.tabstop = 2               -- Tab = 2 spaces
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.number = true         -- show absolute line number for current line
vim.opt.relativenumber = true -- show relative numbers for all other lines
vim.opt.ignorecase = true     -- ignore case when searching
vim.opt.smartcase = true      -- but be case-sensitive if uppercase is used

-- =========================
-- Bootstrap lazy.nvim
-- =========================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =========================
-- Plugins
-- =========================
-- Plugins are split into module files under lua/plugins
-- Each module returns a list or a single plugin spec.
require("lazy").setup({
  require("plugins.theme"),
  require("plugins.treesitter"),
  require("plugins.telescope"),
  require("plugins.lualine"),
  require("plugins.cmp"),
  require("plugins.lsp"),
  require("plugins.git_tools"),
  require("plugins.conform"),
  require("plugins.CopilotChat"),
  { "nvim-tree/nvim-web-devicons", lazy = true },
})

-- =========================
-- Keymaps
-- =========================
require("keymaps")
