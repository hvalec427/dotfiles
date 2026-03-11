local fzf = require("fzf-lua")
local map = vim.keymap.set

local function grep_word_opts()
  return {
    hidden = true,
    no_ignore = false,
    rg_opts = "--column --line-number --no-heading --color=always -i",
  }
end

-- =========================
-- FZF pickers
-- =========================

map("n", "<leader>ff", function()
  fzf.files({
    hidden = true,
    follow = true,
    fd_opts = "--type f --hidden --follow --exclude .git",
    previewer = "builtin",
  })
end, { desc = "[f]ind [f]iles (project files)" })

map("n", "<leader>fF", function()
  fzf.files({
    hidden = true,
    no_ignore = true,
    follow = true,
    fd_opts = "--type f --hidden --follow --no-ignore --exclude .git",
  })
end, { desc = "[f]ind [F]ILES (ignore .gitignore + hidden)" })

map("n", "<leader>fh", function()
  fzf.help_tags()
end, { desc = "[f]ind [h]elp (help tags picker)" })

map("n", "<leader>fk", function()
  fzf.keymaps()
end, { desc = "[f]ind [k]eymaps (keymap picker)" })

map("n", "<leader>fd", function()
  fzf.keymaps()
end, { desc = "[f]ind [d]efs (alternate keymap picker)" })

map("n", "<leader>fw", function()
  fzf.grep_cword(grep_word_opts())
end, { desc = "[f]ind [w]ord (case-insensitive)" })

map("v", "<leader>fw", function()
  fzf.grep_visual(grep_word_opts())
end, { desc = "[f]ind selected [w]ord (case-insensitive)" })

map("n", "<leader>fg", function()
  fzf.live_grep({
    hidden = true,
    no_ignore = false,
  })
end, { desc = "[f]uzzy [g]rep (ignore .gitignore)" })

map("n", "<leader>fG", function()
  fzf.live_grep({
    hidden = true,
    no_ignore = true,
  })
end, { desc = "[f]uzzy [G]REP (hit ALL files)" })

map("n", "<leader><leader>", function()
  fzf.buffers()
end, { desc = "FZF current [b]uffers" })

-- =========================
-- Neo file browser
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
      has_diff = vim.api.nvim_win_get_option(win, "diff")
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
-- LSP references
-- =========================

map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[r]e[n]ame (LSP)" })
map("n", "grr", function()
  fzf.lsp_references()
end, { desc = "LSP references (FZF)" })

map("n", "grR", vim.lsp.buf.references, { desc = "LSP references (no Telescope)" })

-- =========================
-- Which key
-- =========================

map("n", "<leader>?", function()
  require("which-key").show({ global = false })
end, { desc = "Buffer Local Keymaps (which-key)" })

-- =========================
-- Other
-- =========================

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "[e]xpand diagnostic message" })
