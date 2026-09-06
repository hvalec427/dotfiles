local pick = require("mini.pick")

local M = {}

local EXCLUDES = {
  "!.git",
  "!node_modules",
  "!Pods",
  "!build",
  "!.gradle",
  "!DerivedData",
  "!.expo",
  "!dist",
  "!vendor",
  "!.venv",
}

local function apply_visibility(cmd, all)
  table.insert(cmd, "--hidden")
  table.insert(cmd, "--no-ignore")
  if all then
    vim.list_extend(cmd, { "--glob", "!.git" })
  else
    for _, g in ipairs(EXCLUDES) do
      vim.list_extend(cmd, { "--glob", g })
    end
  end
  return cmd
end

local function show_icons(buf_id, items, query)
  pick.default_show(buf_id, items, query, { show_icons = true })
end

M._active = nil

local function restore_query(query)
  if query and #query > 0 then
    vim.schedule(function()
      if pick.is_picker_active() then pick.set_picker_query(query) end
    end)
  end
end

local function files_command(all)
  return apply_visibility({ "rg", "--files", "--color=never" }, all)
end

local function grep_command(all, pattern)
  local cmd = {
    "rg", "--column", "--line-number", "--no-heading",
    "--field-match-separator", "\x00", "--color=never", "--no-fixed-strings",
  }
  apply_visibility(cmd, all)
  local case = vim.o.ignorecase and (vim.o.smartcase and "smart-case" or "ignore-case") or "case-sensitive"
  vim.list_extend(cmd, { "--" .. case, "--", pattern })
  return cmd
end

function M.files(o)
  o = o or {}
  local all = o.all or false
  local cwd = o.cwd
  local name = "Files"
  M._active = {
    name = name,
    all = all,
    relaunch = function(a, q) M.files({ all = a, cwd = cwd, _query = q }) end,
  }
  restore_query(o._query)
  pick.builtin.cli(
    { command = files_command(all) },
    { source = { name = name, cwd = cwd, show = show_icons } }
  )
end

function M.grep(o)
  o = o or {}
  local all = o.all or false
  local pattern = o.pattern or ""
  local cwd = o.cwd
  local name = 'Grep: "' .. pattern .. '"'
  M._active = {
    name = name,
    all = all,
    relaunch = function(a, q) M.grep({ pattern = pattern, all = a, cwd = cwd, _query = q }) end,
  }
  restore_query(o._query)
  pick.builtin.cli(
    { command = grep_command(all, pattern) },
    { source = { name = name, cwd = cwd, show = show_icons } }
  )
end

function M.grep_live(o)
  o = o or {}
  local all = o.all or false
  local cwd = o.cwd or vim.fn.getcwd()
  local name = "Grep live"
  M._active = {
    name = name,
    all = all,
    relaunch = function(a, q) M.grep_live({ all = a, cwd = cwd, _query = q }) end,
  }

  local sys = { kill = function() end }
  local match = function(_, _, query)
    pcall(function() sys:kill() end)
    if #query == 0 then
      sys = { kill = function() end }
      return pick.set_picker_items({}, { do_match = false })
    end
    sys = pick.set_picker_items_from_cli(grep_command(all, table.concat(query)), {
      set_items_opts = { do_match = false },
      spawn_opts = { cwd = cwd },
    })
  end

  restore_query(o._query)
  pick.start({
    source = { name = name, items = {}, match = match, cwd = cwd, show = show_icons },
  })
end

function M.toggle_all()
  local a = M._active
  if not (a and pick.is_picker_active()) then return end
  local opts = pick.get_picker_opts()
  if not (opts and opts.source and opts.source.name == a.name) then
    vim.notify("No visibility toggle for this picker", vim.log.levels.INFO)
    return
  end
  local query = pick.get_picker_query()
  pick.stop()
  vim.schedule(function() a.relaunch(not a.all, query) end)
end

return M
