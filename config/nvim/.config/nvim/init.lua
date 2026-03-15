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
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.signcolumn = "yes"    -- Always show the sign column to avoid text shifting when diagnostics appear
vim.opt.scrolloff = 8         -- Keep eight lines visible above/below the cursor for better context while navigating
vim.opt.updatetime = 200      -- Reduce the cursor-hold delay so LSP diagnostics/hover update more quickly
vim.opt.swapfile = false      -- ignore swap files
vim.opt.undofile = true       -- enable undofile history

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
  require("plugins.fzf"),
  require("plugins.lualine"),
  require("plugins.cmp"),
  require("plugins.autopairs"),
  require("plugins.lsp"),
  require("plugins.git_tools"),
  require("plugins.navigator"),
  require("plugins.whichkey"),
  require("plugins.conform"),
  require("plugins.neo-tree"),
})

-- =========================
-- Keymaps
-- =========================
require("keymaps")

-- =========================
-- Auto quit
-- =========================
vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Close Neovim when only sidebar windows remain",
  callback = function()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    -- neo-tree handles if there is only a single window left
    if #wins == 1 and vim.bo[vim.api.nvim_win_get_buf(wins[1])].filetype ~= "aerial" then
      return
    end

    local sidebar_fts = { aerial = true, ["neo-tree"] = true }
    for _, winid in ipairs(wins) do
      if vim.api.nvim_win_is_valid(winid) then
        local bufnr = vim.api.nvim_win_get_buf(winid)
        local filetype = vim.bo[bufnr].filetype
        -- If any visible windows are not sidebars, early return
        if not sidebar_fts[filetype] then
          return
        -- If the visible window is a sidebar, remove that type from detection
        else
          sidebar_fts[filetype] = nil
        end
      end
    end

    if #vim.api.nvim_list_tabpages() > 1 then
      vim.cmd.tabclose()
    else
      vim.cmd.qall()
    end
  end,
})
