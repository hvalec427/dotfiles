-- Shared configuration helpers for Neovim

vim.g.mapleader = " "             -- Space as leader
vim.opt.clipboard = "unnamedplus" -- System clipboard
vim.opt.tabstop = 2               -- Tab = 2 spaces
vim.opt.shiftwidth = 2            -- Indent = 2 spaces
vim.opt.expandtab = true          -- Use spaces instead of tabs
vim.opt.autoread = true           -- Reload files changed outside Neovim
vim.opt.number = true         -- show absolute line number for current line
vim.opt.relativenumber = true -- show relative numbers for all other lines
vim.opt.ignorecase = true     -- ignore case when searching
vim.opt.smartcase = true      -- but be case-sensitive if uppercase is used
vim.opt.completeopt = { "menuone", "noselect" } -- blink.cmp drives the completion menu
vim.opt.signcolumn = "yes"    -- Always show the sign column to avoid text shifting when diagnostics appear
vim.opt.scrolloff = 8         -- Keep eight lines visible around the cursor for context
vim.opt.updatetime = 200      -- Reduce cursor-hold delay for diagnostics/hover
vim.opt.swapfile = false      -- ignore swap files
vim.opt.undofile = true       -- enable undofile history

vim.diagnostic.config({
  virtual_text = true,     -- show error text inline
  underline = true,        -- underline the offending code
  signs = true,            -- show diagnostic icons in the sign column
  update_in_insert = true, -- update while typing
})

-- Reload files changed outside Neovim when refocusing or entering a buffer.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})

-- Restore the cursor to its last position when reopening a file (skipping commit buffers).
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
