-- Side-by-side live preview for mini.pick.
--
-- mini.pick combines everything into a single window, so its built-in preview
-- (<Tab>) *replaces* the match list rather than sitting next to it. This module
-- fakes a two-pane layout: the picker's own window is squeezed into a left pane
-- (via `window.config`, which mini re-applies on every refresh) and a separate,
-- non-focusable float on the right shows the current item's contents, updated as
-- you navigate. Rendering reuses `MiniPick.default_preview`, so we get treesitter
-- highlighting and automatic scroll-to-line for grep results for free.

local M = {}
local uv = vim.uv or vim.loop

local BOX_W, BOX_H = 0.85, 0.85 -- overall footprint (fraction of screen)
local LEFT_FRAC = 0.42          -- list pane share of the inner width
local GAP = 2                   -- columns between the two panes

-- CursorMoved does not fire while mini.pick runs its blocking getcharstr loop,
-- so navigation is detected by polling the list window's cursor line on a libuv
-- timer (the same mechanism mini uses for its own lost-focus tracker). Query
-- changes are caught separately via the MiniPickMatch event.
local POLL_MS = 80

local state = { win = nil, poll = nil, debounce = nil, last_key = nil }

-- Geometry for both panes, kept in one place so they never drift apart.
-- Returns (left_config, right_config) for `nvim_open_win`/`window.config`.
local function geometry()
  local W = vim.o.columns
  local H = vim.o.lines - vim.o.cmdheight
  local total_w = math.floor(W * BOX_W)
  local total_h = math.floor(H * BOX_H)
  local x0 = math.floor((W - total_w) / 2)
  local y0 = math.floor((H - total_h) / 2)

  -- `inner` is the sum of both panes' *content* widths (each pane also spends
  -- 2 columns on its rounded border, plus GAP between the two boxes).
  local inner = total_w - 4 - GAP
  local left_w = math.max(20, math.floor(inner * LEFT_FRAC))
  local right_w = math.max(20, inner - left_w)
  local row = y0 + 1
  local height = math.max(3, total_h - 2)

  local left = {
    relative = "editor",
    anchor = "NW",
    row = row,
    col = x0 + 1,
    width = left_w,
    height = height,
    border = "rounded",
  }
  local right = {
    relative = "editor",
    anchor = "NW",
    row = row,
    -- left border (1) + left content + left border (1) + GAP + right border (1)
    col = x0 + left_w + 3 + GAP,
    width = right_w,
    height = height,
    border = "rounded",
    focusable = false,
    style = "minimal",
    zindex = 250,
  }
  return left, right
end

-- `window.config` for mini.pick's list window: the left pane.
function M.win_config()
  local left = geometry()
  return left
end

-- Scroll the (non-focusable) preview float by half a page. `dir` is 1 (down) or
-- -1 (up). Meant to be bound to picker mappings, so it forces a redraw itself
-- (mini.pick's getcharstr loop won't repaint on its own).
function M.scroll(dir)
  if not (state.win and vim.api.nvim_win_is_valid(state.win)) then return end
  vim.api.nvim_win_call(state.win, function()
    local height = vim.api.nvim_win_get_height(0)
    local step = math.max(1, math.floor(height / 2)) * dir
    local last = vim.api.nvim_buf_line_count(0)
    local view = vim.fn.winsaveview()
    view.topline = math.max(1, math.min(view.topline + step, last))
    view.lnum = math.max(1, math.min(view.lnum + step, last))
    vim.fn.winrestview(view)
  end)
  pcall(vim.cmd.redraw)
end

local MiniPick
local function mp()
  MiniPick = MiniPick or require("mini.pick")
  return MiniPick
end

-- Short, tilde-relative label for the float title.
local function item_label(item)
  if item == nil then return "" end
  if type(item) == "table" then
    if item.text then return item.text end
    if item.bufnr then return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(item.bufnr), ":~:.") end
    return ""
  end
  -- Strip any grep location suffix (path is NUL-separated from lnum/col/text).
  local path = tostring(item):gsub("%z.*$", "")
  return vim.fn.fnamemodify(path, ":~:.")
end

-- Identity used to skip redundant repaints. Unlike the label it must stay
-- distinct across grep hits in the same file, so it keeps the location suffix.
local function item_key(item)
  if item == nil then return "\0nil" end
  if type(item) == "table" then
    return table.concat({ item.text or "", tostring(item.bufnr), tostring(item.lnum) }, "\0")
  end
  return tostring(item)
end

local function ensure_win()
  if state.win and vim.api.nvim_win_is_valid(state.win) then return true end
  local _, right = geometry()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  local ok, win = pcall(vim.api.nvim_open_win, buf, false, vim.tbl_extend("force", right, { noautocmd = true }))
  if not ok then return false end
  state.win = win
  vim.wo[win].wrap = false
  vim.wo[win].cursorline = false
  vim.wo[win].winhighlight = "NormalFloat:Normal,FloatBorder:MiniPickBorder"
  return true
end

local function do_update()
  if not mp().is_picker_active() then return end
  if not ensure_win() then return end

  local matches = mp().get_picker_matches()
  local item = matches and matches.current or nil

  -- Skip redundant repaints (poll and MiniPickMatch can both fire for the same
  -- item) to avoid flicker and needless file reads.
  local key = item_key(item)
  if key == state.last_key then return end
  state.last_key = key

  -- Fresh buffer per render so treesitter/filetype from a previous item never
  -- bleeds through; the outgoing buffer is wiped automatically (bufhidden).
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_win_set_buf(state.win, buf)

  local _, right = geometry()
  right.title = " " .. item_label(item) .. " "
  right.title_pos = "center"
  pcall(vim.api.nvim_win_set_config, state.win, right)

  if item ~= nil then
    -- Honor a picker's own `source.preview` (e.g. the git-status picker renders
    -- a diff); otherwise use default_preview, which finds this window via
    -- bufwinid(buf) and scrolls it to the target line for grep hits.
    local opts = mp().get_picker_opts()
    local preview = opts and opts.source and opts.source.preview
    if type(preview) ~= "function" then preview = mp().default_preview end
    pcall(preview, buf, item)
  end

  -- mini.pick blocks in getcharstr() and repaints only via explicit redraws, so
  -- our buffer write is invisible until forced; without this the preview trails
  -- the selection by one step (and is blank until the first move).
  pcall(vim.cmd.redraw)
end

local function schedule_update()
  if not state.debounce then return end
  state.debounce:stop()
  state.debounce:start(25, 0, vim.schedule_wrap(do_update))
end

-- Runs on the poll timer during the picker loop. Repaint is driven off the
-- current item itself (do_update dedups via item_key), so it can never trail
-- the selection the way gating on a separately-updated cursor line did.
local function poll_tick()
  if not mp().is_picker_active() then return end
  do_update()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("MiniPickSidePreview", { clear = true })
  if not state.debounce then state.debounce = uv.new_timer() end
  if not state.poll then state.poll = uv.new_timer() end

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniPickStart",
    callback = function()
      state.last_key = nil
      ensure_win()
      state.poll:stop()
      state.poll:start(POLL_MS, POLL_MS, vim.schedule_wrap(poll_tick))
      vim.schedule(do_update)
    end,
  })

  -- Query changes (and initial item load) can move the current item without
  -- moving the cursor line; MiniPickMatch covers those.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniPickMatch",
    callback = schedule_update,
  })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "MiniPickStop",
    callback = function()
      if state.poll then state.poll:stop() end
      if state.debounce then state.debounce:stop() end
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        pcall(vim.api.nvim_win_close, state.win, true)
      end
      state.win = nil
    end,
  })

  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if state.win and vim.api.nvim_win_is_valid(state.win) then
        local _, right = geometry()
        pcall(vim.api.nvim_win_set_config, state.win, right)
      end
    end,
  })
end

return M
