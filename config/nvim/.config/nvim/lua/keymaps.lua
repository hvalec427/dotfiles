local map = vim.keymap.set

-- =========================
-- fff pickers
-- =========================

map("n", "ff", function() require("fff").find_files() end, { desc = "[f]ind [f]iles (fff)" })
map("n", "fd", function() require("fff").find_files_in_dir(vim.fn.expand("%:p:h")) end,
  { desc = "[f]ind in current [d]ir (fff)" })
map("n", "fs", function()
  require("fff").find_files({
    query = "git:modified",
    preview_fn = function(item, bufnr, _win)
      require("fff.file_picker.preview").state.bufnr = bufnr
      local file = item.relative_path or item.path or ""
      local diff = vim.fn.systemlist("git diff HEAD -- " .. vim.fn.shellescape(file))
      if #diff == 0 then
        diff = vim.fn.systemlist("git diff --cached -- " .. vim.fn.shellescape(file))
      end
      if #diff == 0 then diff = { "(no diff)" } end
      local filtered = {}
      local in_hunk = false
      for _, line in ipairs(diff) do
        if line:match("^@@") then in_hunk = true end
        if in_hunk then filtered[#filtered + 1] = line end
      end
      if #filtered > 0 then diff = filtered end
      vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, diff)
      vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
      vim.api.nvim_set_option_value("filetype", "diff", { buf = bufnr })
    end,
  })
end, { desc = "[f]ile [s]tatus (git changed)" })
map("n", "fg", function()
  local before_wins = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    before_wins[w] = true
  end

  require("fff").live_grep()

  if _G._fff_last_grep_query then
    vim.defer_fn(function()
      vim.api.nvim_input(_G._fff_last_grep_query)
    end, 100)

    -- After query is fed, set up clear-on-first-keypress via buffer-local keymaps.
    -- Works if fff's prompt is a normal vim insert-mode buffer.
    vim.defer_fn(function()
      local buf = vim.api.nvim_get_current_buf()
      local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      local function remove_all()
        for i = 1, #chars do
          pcall(vim.keymap.del, 'i', chars:sub(i, i), { buffer = buf })
        end
      end
      for i = 1, #chars do
        local c = chars:sub(i, i)
        vim.keymap.set('i', c, function()
          remove_all()
          return '<C-u>' .. c
        end, { buffer = buf, expr = true, nowait = true })
      end
    end, 150)
  end

  -- find the new floating window fff just opened and watch it close
  vim.defer_fn(function()
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if not before_wins[w] then
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(w),
          once = true,
          callback = function()
            local ok, picker_ui = pcall(require, "fff.picker_ui")
            if ok and picker_ui.state and type(picker_ui.state.query) == "string" and picker_ui.state.query ~= "" then
              _G._fff_last_grep_query = picker_ui.state.query
            end
          end,
        })
        break
      end
    end
  end, 50)
end, { desc = "Live [g]rep, resume last query (fff)" })
local function fff_grep_with_query(query)
  local before_wins = {}
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    before_wins[w] = true
  end

  require("fff").live_grep({ query = query })

  vim.defer_fn(function()
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if not before_wins[w] then
        vim.api.nvim_create_autocmd("WinClosed", {
          pattern = tostring(w),
          once = true,
          callback = function()
            local ok, picker_ui = pcall(require, "fff.picker_ui")
            if ok and picker_ui.state and type(picker_ui.state.query) == "string" and picker_ui.state.query ~= "" then
              _G._fff_last_grep_query = picker_ui.state.query
            end
          end,
        })
        break
      end
    end
  end, 50)
end

map("n", "fw", function()
  fff_grep_with_query(vim.fn.expand("<cword>"))
end, { desc = "[g]rep current [w]ord (fff)" })

map("v", "fw", function()
  vim.cmd('noau normal! "vy"')
  fff_grep_with_query(vim.fn.getreg("v"))
end, { desc = "[g]rep visual selection (fff)" })

-- =========================
-- Neo-tree
-- =========================

map("n", "<leader>n", function()
  require("neo-tree.command").execute({ toggle = true, reveal = true })
end, { desc = "[n]eo-tree toggle" })

-- =========================
-- Git
-- =========================

-- Removed fzf-lua Git status mapping

local function close_diff_windows()
  local ok, lib = pcall(require, "diffview.lib")
  if ok and lib.get_current_view() then
    vim.cmd("DiffviewClose")
    return
  end

  local current_win = vim.api.nvim_get_current_win()
  local diff_found = false

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local has_diff = false
    pcall(function()
      has_diff = vim.api.nvim_get_option_value("diff", { win = win })
    end)

    if has_diff then
      diff_found = true
      if win ~= current_win then
        pcall(vim.api.nvim_win_close, win, true)
      end
    end
  end

  if diff_found then
    vim.cmd("diffoff!")
  end
end

map("n", "<leader>gD", "<cmd>DiffviewOpen<CR>", { desc = "Diff working directory" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis HEAD<CR>", { desc = "Diff current file vs last commit" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", { desc = "File history (current file)" })
map("n", "<leader>gq", close_diff_windows, { desc = "Close diff (Diffview or Gitsigns)" })

-- =========================
-- LSP
-- =========================

map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[r]e[n]ame (LSP)" })

map("n", "grd", vim.lsp.buf.definition, { desc = "Go to [d]efinition (LSP)" })

-- Use built-in references mapping only
map("n", "grR", vim.lsp.buf.references, { desc = "LSP references (built-in)" })

-- =========================
-- Copilot
-- =========================

map(
  "i",
  "<C-J>",
  "copilot#Accept(\"\\<CR>\")",
  { expr = true, silent = true, noremap = false, replace_keycodes = false }
)

-- =========================
-- Which-key
-- =========================

map("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer local keymaps (which-key)" })

-- =========================
-- Diagnostics / Code actions
-- =========================

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Expand diagnostic" })

-- Use built-in code actions
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })

-- =========================
-- Misc
-- =========================

-- Prevent Ctrl+Z from suspending Neovim
map({ "n", "v", "i", "t" }, "<C-z>", "<Nop>", { desc = "Disable suspend" })

-- Paste without overwriting register
map("v", "p", '"_dP', { desc = "Paste without overwriting register" })

-- Quick escape from insert mode
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("i", "kj", "<Esc>", { desc = "Exit insert mode" })

-- increase resize steps
vim.keymap.set("n", "<C-w>+", "<cmd>resize +5<CR>", { silent = true })
vim.keymap.set("n", "<C-w>-", "<cmd>resize -5<CR>", { silent = true })
vim.keymap.set("n", "<C-w>>", "<cmd>vertical resize +15<CR>", { silent = true })
vim.keymap.set("n", "<C-w><", "<cmd>vertical resize -15<CR>", { silent = true })
