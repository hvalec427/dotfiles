local telescope = require("telescope.builtin")
local map = vim.keymap.set
local M = {}

-- Telescope pickers
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

-- git
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

-- LSP references
map("n", "grr", function()
  telescope.lsp_references({
    initial_mode = "normal",
    include_current_file = true,
    include_declaration = false,
    show_line = true,
  })
end, { desc = "LSP references (Telescope)" })
map("n", "grR", vim.lsp.buf.references, { desc = "LSP references (no Telescope)" })

-- telescope browser
map("n", "<leader>fb", function()
  require("telescope").extensions.file_browser.file_browser({
    path = "%:p:h",
    select_buffer = true,
    initial_mode = "normal",
  })
end, { desc = "[f]ile [b]rowser (buffer dir)" })

function M.telescope_file_browser_mappings(fb_actions)
  return {
    ["n"] = {
      ["<leader>n"] = fb_actions.create,
      ["<leader>r"] = fb_actions.rename,
      ["<leader>d"] = fb_actions.remove,
      ["<leader>m"] = fb_actions.move,
      ["<leader>ap"] = function(prompt_bufnr)
        local actions = require("telescope.actions.state")
        local entry = actions.get_selected_entry()
        local path = entry and entry.path or nil
        if path then
          vim.fn.setreg('+', path)
          print("Copied to clipboard: " .. path)
        else
          print("No path selected.")
        end
      end,
      ["<leader>p"] = function(prompt_bufnr)
        local actions = require("telescope.actions.state")
        local entry = actions.get_selected_entry()
        local path = entry and entry.path or nil
        if path then
          local cwd = vim.fn.getcwd()
          local relpath = vim.fn.fnamemodify(path, ':~:.')
          vim.fn.setreg('+', relpath)
          print("Copied relative path: " .. relpath)
        else
          print("No path selected.")
        end
      end,
    },
  }
end

-- Copilot
map("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false,
  desc = "Copilot Accept",
})

--- Copilot Chat
local copilotchat = require("CopilotChat")

-- Normal: open chat + include *this* buffer explicitly
map("n", "<leader>cc", function()
  local bufnr = vim.api.nvim_get_current_buf()
  copilotchat.open({
    sticky = { "#buffer:" .. bufnr },
  })
end, { desc = "CopilotChat: current buffer" })

-- Visual: open chat + include selection
map("v", "<leader>cc", function()
  copilotchat.open({
    sticky = { "#selection" },
  })
end, { desc = "CopilotChat: selection" })

-- other
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "[e]xpand diagnostic message" })

return M
