local telescope = require("telescope.builtin")
local map = vim.keymap.set

-- =========================
-- Telescope pickers
-- =========================

map("n", "<leader>ff", function()
  telescope.find_files({})
end, { desc = "[f]ind [f]iles (ignore .gitignore, skip junk)" })

map("n", "<leader>fF", function()
  telescope.find_files({
    no_ignore = true,
    hidden = true,
  })
end, { desc = "[f]ind [F]ILES (even node_modules)" })

map("n", "<leader>fg", function()
  telescope.live_grep({})
end, { desc = "[f]uzzy [g]rep (ignore .gitignore)" })

map("n", "<leader>fG", function()
  telescope.live_grep({
    additional_args = function(_)
      return { "--no-ignore", "--hidden" }
    end,
  })
end, { desc = "[f]uzzy [G]REP (hit ALL files)" })

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
  telescope.git_status({
    initial_mode = "normal",
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
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[r]e[n]ame (LSP)" })

-- =========================
-- LSP references
-- =========================

map("n", "grr", function()
  telescope.lsp_references({
    initial_mode = "normal",
    include_current_file = true,
    include_declaration = false,
    show_line = true,
  })
end, { desc = "LSP references (Telescope)" })

map("n", "grR", vim.lsp.buf.references, { desc = "LSP references (no Telescope)" })

-- =========================
-- Other
-- =========================

map("n", "<leader>e", vim.diagnostic.open_float, { desc = "[e]xpand diagnostic message" })

