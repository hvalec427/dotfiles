-- The Farmer Was Replaced's in-game editor indents with tabs, while the stock
-- python ftplugin uses 4 spaces; match the game so files don't end up mixed.
if vim.api.nvim_buf_get_name(0):find("TheFarmerWasReplaced", 1, true) then
  vim.bo.expandtab = false
  vim.bo.tabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.softtabstop = 0
end
