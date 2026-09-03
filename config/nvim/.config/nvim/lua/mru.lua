local M = {}

-- Most-recent-first list of file paths, tracked live within the session.
local mru = {}
local cycling = false
local cycle_index = 1
local cycle_gen = 0

local MAX = 20

local function is_trackable(buf)
  if vim.bo[buf].buftype ~= "" then return false end
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then return false end
  return vim.fn.filereadable(name) == 1
end

local function touch(path)
  for i, p in ipairs(mru) do
    if p == path then
      table.remove(mru, i)
      break
    end
  end
  table.insert(mru, 1, path)
  while #mru > MAX do
    table.remove(mru)
  end
end

local function end_cycle()
  cycling = false
  local name = vim.api.nvim_buf_get_name(0)
  if name ~= "" then touch(name) end
end

-- dir: +1 = older, -1 = newer
function M.cycle(dir)
  if #mru < 2 then return end
  if not cycling then
    cycling = true
    cycle_index = 1
  end
  cycle_index = math.max(1, math.min(#mru, cycle_index + dir))
  local target = mru[cycle_index]
  if target and vim.fn.filereadable(target) == 1 then
    vim.cmd.edit(vim.fn.fnameescape(target))
  end
  cycle_gen = cycle_gen + 1
  local my = cycle_gen
  vim.defer_fn(function()
    if my == cycle_gen then end_cycle() end
  end, 1200)
end

function M.pick()
  local cur = vim.api.nvim_buf_get_name(0)
  local items = {}
  for _, p in ipairs(mru) do
    if p ~= cur and vim.fn.filereadable(p) == 1 then
      items[#items + 1] = p
    end
  end
  if #items == 0 then
    vim.notify("No recent files", vim.log.levels.INFO)
    return
  end

  local lines = {}
  local width = 20
  for i, p in ipairs(items) do
    local disp = vim.fn.fnamemodify(p, ":~:.")
    lines[i] = disp
    width = math.max(width, #disp)
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local height = math.min(#lines, 10)
  width = math.min(width + 2, math.floor(vim.o.columns * 0.6))
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " Recent files ",
    title_pos = "center",
  })
  vim.wo[win].cursorline = true

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  local function move(dir)
    local line = vim.api.nvim_win_get_cursor(win)[1]
    line = math.max(1, math.min(#items, line + dir))
    vim.api.nvim_win_set_cursor(win, { line, 0 })
  end
  local function open_sel()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local target = items[line]
    close()
    if target then vim.cmd.edit(vim.fn.fnameescape(target)) end
  end

  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<C-n>", function() move(1) end, opts)
  vim.keymap.set("n", "<C-p>", function() move(-1) end, opts)
  vim.keymap.set("n", "<C-j>", function() move(1) end, opts)
  vim.keymap.set("n", "<C-k>", function() move(-1) end, opts)
  -- Block vim-tmux-navigator from stealing focus to another split/pane
  -- while this floating window is open.
  vim.keymap.set("n", "<C-h>", "<Nop>", opts)
  vim.keymap.set("n", "<C-l>", "<Nop>", opts)
  vim.keymap.set("n", "<CR>", open_sel, opts)
  vim.keymap.set("n", "q", close, opts)
  vim.keymap.set("n", "<Esc>", close, opts)
end

function M.setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("mru_tracking", { clear = true }),
    callback = function(args)
      if cycling then return end
      if is_trackable(args.buf) then
        touch(vim.api.nvim_buf_get_name(args.buf))
      end
    end,
  })
end

return M
