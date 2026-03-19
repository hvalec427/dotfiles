-- =========================
-- Basic Options
-- =========================
require("common")

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
  require("plugins.copilot"),
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
