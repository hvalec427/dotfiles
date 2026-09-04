local map = vim.keymap.set

-- =========================
-- mini.pick pickers
-- =========================

-- Find files including hidden ones (rg skips hidden files AND dirs by default,
-- which hides everything under paths like .config/). Exclude the .git dir.
map("n", "ff", function()
  local pick = require("mini.pick")
  pick.builtin.cli(
    { command = { "rg", "--files", "--hidden", "--glob", "!.git", "--color=never" } },
    {
      source = {
        name = "Files (incl. hidden)",
        show = function(buf_id, items, query)
          pick.default_show(buf_id, items, query, { show_icons = true })
        end,
      },
    }
  )
end, { desc = "[f]ind [f]iles (incl. hidden)" })
map("n", "fr", function() require("mini.pick").builtin.resume() end, { desc = "[f]ind [r]esume last picker" })
map("n", "<leader><space>", function()
  local pick = require("mini.pick")
  local cur = vim.api.nvim_get_current_buf()
  local alt = vim.fn.bufnr("#")
  local infos = vim.fn.getbufinfo({ buflisted = 1 })
  table.sort(infos, function(a, b) return a.lastused > b.lastused end)

  -- Front order: alternate, then current, then the rest most-recently-used.
  -- So with recency 1,2,3 and current 1, the list reads 2 1 3 -- the previous
  -- buffer sits on top for an instant <CR>.
  local order, seen = {}, {}
  local function push(bufnr)
    if bufnr and bufnr > 0 and not seen[bufnr] and vim.fn.buflisted(bufnr) == 1 then
      seen[bufnr] = true
      order[#order + 1] = bufnr
    end
  end
  push(alt)
  push(cur)
  for _, info in ipairs(infos) do push(info.bufnr) end

  local items = {}
  for _, bufnr in ipairs(order) do
    local n = vim.api.nvim_buf_get_name(bufnr)
    local name = n ~= "" and vim.fn.fnamemodify(n, ":~:.") or "[No Name]"
    items[#items + 1] = { text = name, bufnr = bufnr }
  end

  pick.start({
    source = {
      name = "Buffers (MRU)",
      items = items,
      show = function(buf_id, its, query)
        pick.default_show(buf_id, its, query, { show_icons = true })
      end,
    },
  })
end, { desc = "Open buffers (MRU)" })
map("n", "<Tab>", "<cmd>e #<CR>", { desc = "Toggle alternate file" })

map("n", "fd", function()
  require("mini.pick").builtin.files(nil, { source = { cwd = vim.fn.expand("%:p:h") } })
end, { desc = "[f]ind in current [d]ir" })

map("n", "fs", function()
  require("mini.extra").pickers.git_files({ scope = "modified" })
end, { desc = "[f]ile [s]tatus (git changed)" })

map("n", "fg", function() require("mini.pick").builtin.grep_live() end, { desc = "Live [g]rep" })

map("n", "fw", function()
  require("mini.pick").builtin.grep({ pattern = vim.fn.expand("<cword>") })
end, { desc = "[g]rep current [w]ord" })

map("v", "fw", function()
  vim.cmd('noau normal! "vy"')
  require("mini.pick").builtin.grep({ pattern = vim.fn.getreg("v") })
end, { desc = "[g]rep visual selection" })

-- =========================
-- Oil (file explorer)
-- =========================

-- Open a floating oil explorer at the current file's directory
map("n", "<leader>n", function() require("oil").toggle_float() end, { desc = "Oil (floating)" })

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
-- Movement
-- =========================

map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down, centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up, centered" })
map("n", "<C-f>", "<C-f>zz", { desc = "Full-page down, centered" })
map("n", "<C-b>", "<C-b>zz", { desc = "Full-page up, centered" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Grow/shrink selection by treesitter node (falls back to LSP selection range)
map({ "n", "x", "o" }, "<A-o>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_parent(vim.v.count1)
  else
    vim.lsp.buf.selection_range(vim.v.count1)
  end
end, { desc = "Select parent node (grow)" })

map({ "n", "x", "o" }, "<A-i>", function()
  if vim.treesitter.get_parser(nil, nil, { error = false }) then
    require("vim.treesitter._select").select_child(vim.v.count1)
  else
    vim.lsp.buf.selection_range(-vim.v.count1)
  end
end, { desc = "Select child node (shrink)" })

-- =========================
-- Terminal runners
-- =========================

local new_runner = require("runner").new_runner

local lazygit = new_runner("lazygit", { floating = true })
vim.api.nvim_create_user_command("LazyGit", lazygit, {})
map({ "n", "x" }, "<leader>l", lazygit, { desc = "LazyGit (floating)" })

-- =========================
-- Completion (native LSP popup)
-- =========================

-- Tab / Shift-Tab navigate the completion popup when it's visible,
-- otherwise insert a literal Tab. Confirm a selection with <C-y>.
map("i", "<Tab>", function() return vim.fn.pumvisible() == 1 and "<C-n>" or "<Tab>" end, { expr = true })
map("i", "<S-Tab>", function() return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>" end, { expr = true })

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
