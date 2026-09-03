-- Shared configuration helpers for Neovim

vim.g.mapleader = " "             -- Space as leader
vim.opt.clipboard = "unnamedplus" -- System clipboard
vim.opt.tabstop = 2               -- Tab = 2 spaces
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoread = true
vim.opt.number = true         -- show absolute line number for current line
vim.opt.relativenumber = true -- show relative numbers for all other lines
vim.opt.ignorecase = true     -- ignore case when searching
vim.opt.smartcase = true      -- but be case-sensitive if uppercase is used
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.signcolumn = "yes"    -- Always show the sign column to avoid text shifting when diagnostics appear
vim.opt.scrolloff = 8         -- Keep eight lines visible around the cursor for context
vim.opt.updatetime = 200      -- Reduce cursor-hold delay for diagnostics/hover
vim.opt.swapfile = false      -- ignore swap files
vim.opt.undofile = true       -- enable undofile history

vim.diagnostic.config({
  virtual_text = true, -- show error text inline
  underline = true,
  signs = true,
  update_in_insert = true, -- update while typing
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  desc = "jump to last pos when opening a file",
  callback = function(args)
    local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line("$")
    local not_commit = vim.b[args.buf].filetype ~= "commit"
    if valid_line and not_commit then
      vim.cmd([[normal! g`"]])
    end
  end,
})

-- Experimental Neovim 0.12 message + cmdline UI (vim._core.ui2).
-- pcall-guarded so older Neovim (without this module) still loads cleanly.
pcall(function()
  require("vim._core.ui2").enable({
    enable = true,
    msg = {
      targets = "cmd",                    -- default message target: the cmdline
      cmd = { height = 0.5 },             -- max height when expanded past 'cmdheight'
      dialog = { height = 0.5 },          -- modal prompt window
      msg = { height = 0.5, timeout = 4000 }, -- ephemeral message window
      pager = { height = 1 },             -- :messages / non-collapsed messages
    },
  })
end)

return {}
