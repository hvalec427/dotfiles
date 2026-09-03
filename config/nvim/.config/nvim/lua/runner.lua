local M = {}

-- Returns a function that launches `cmd` in a terminal. With
-- `opts.floating = true` it opens in a centered floating window that
-- auto-closes when the program exits; otherwise it opens in a new tab.
function M.new_runner(cmd, opts)
  opts = opts or {}
  return function()
    if opts.floating then
      local width = math.floor(vim.o.columns * 0.9)
      local height = math.floor(vim.o.lines * 0.9)
      local buf = vim.api.nvim_create_buf(false, true)
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        style = "minimal",
        border = "rounded",
      })
      vim.fn.jobstart(cmd, {
        term = true,
        on_exit = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
          -- Reload buffers the program may have changed on disk.
          vim.cmd("checktime")
        end,
      })
      vim.cmd("startinsert")
    else
      vim.cmd("tabnew")
      vim.fn.jobstart(cmd, { term = true })
      vim.cmd("startinsert")
    end
  end
end

return M
