local fzf = require("fzf-lua")
local map = vim.keymap.set
local fzf_options = require("plugins.fzf")

-- =========================
-- Shared FZF options (defined in plugins.fzf)
-- =========================

local file_opts = fzf_options.file_opts
local grep_opts = fzf_options.grep_opts

-- =========================
-- FZF pickers
-- =========================

map("n", "<leader>ff", function()
  fzf.files(file_opts)
end, { desc = "[f]ind [f]iles (project files)" })

map("n", "<leader>fh", function()
  fzf.help_tags()
end, { desc = "[f]ind [h]elp" })

map("n", "<leader>fk", function()
  fzf.keymaps()
end, { desc = "[f]ind [k]eymaps" })

map("n", "<leader>fd", function()
  fzf.lsp_definitions()
end, { desc = "[f]ind [d]efinitions" })

map("n", "<leader>fw", function()
  fzf.grep_cword(grep_opts)
end, { desc = "[f]ind [w]ord" })

map("v", "<leader>fw", function()
  fzf.grep_visual(grep_opts)
end, { desc = "[f]ind selected [w]ord" })

map("n", "<leader>fg", function()
  fzf.live_grep(grep_opts)
end, { desc = "[f]uzzy [g]rep (respect .gitignore)" })

map("n", "<leader><leader>", function()
  fzf.buffers()
end, { desc = "FZF current [b]uffers" })

-- =========================
-- Neo-tree
-- =========================

map("n", "<leader>n", function()
  require("neo-tree.command").execute({ toggle = true, reveal = true })
end, { desc = "[n]eo-tree toggle" })

-- =========================
-- Git
-- =========================

map("n", "<leader>fs", function()
  fzf.git_status({
    previewer = "git_diff",
  })
end, { desc = "[f]ile [s]tatus (Git status picker)" })

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

map("n", "grr", function()
  fzf.lsp_references()
end, { desc = "LSP references (FZF)" })

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

map("n", "<leader>ca", function()
  fzf.lsp_code_actions()
end, { desc = "Code actions" })

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
