local M = {}

-- Resolve a real (symlink-free) directory to launch tools in. Tools like
-- scooter/ripgrep do NOT follow directory symlinks, so if Neovim's cwd is
-- above a symlinked config dir (e.g. ~/.config/nvim -> ~/dev/dotfiles/...),
-- searching finds nothing. We resolve the current file's directory through
-- symlinks and prefer its git root.
local function resolve_root()
  local file = vim.api.nvim_buf_get_name(0)
  local dir = file ~= "" and vim.fn.fnamemodify(file, ":p:h") or vim.fn.getcwd()
  dir = vim.fn.resolve(dir)
  local git_root = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error == 0 and git_root and git_root ~= "" then
    return git_root
  end
  return dir
end

-- Returns a function that launches `cmd` in a terminal. With
-- `opts.floating = true` it opens in a centered floating window that
-- auto-closes when the program exits; otherwise it opens in a new tab.
-- The terminal runs in the resolved project root (see resolve_root).
function M.new_runner(cmd, opts)
  opts = opts or {}
  return function()
    local root = resolve_root()
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
        cwd = root,
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
      vim.fn.jobstart(cmd, { term = true, cwd = root })
      vim.cmd("startinsert")
    end
  end
end

return M
