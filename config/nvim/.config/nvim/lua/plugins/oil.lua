return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    local oil = require("oil")
    local FIELD_NAME = require("oil.constants").FIELD_NAME

    -- Close oil, but if there are unsaved edits ask to Save / Discard / Cancel.
    local function close_with_prompt()
      local close = function() require("oil.actions").close.callback() end
      if not vim.bo.modified then
        close()
        return
      end
      local choice = vim.fn.confirm("You have unsaved changes.", "&Save\n&Discard\n&Cancel", 3)
      if choice == 1 then -- Save
        oil.save({ confirm = false }, function(err)
          if not err or err == "Canceled" then
            vim.schedule(close)
          end
        end)
      elseif choice == 2 then -- Discard
        -- Floating oil only closes the window, keeping the buffer (and its
        -- pending mutations) alive, so reset it to the on-disk state first.
        oil.discard_all_changes()
        close()
      end
      -- choice == 3 or 0 (Cancel): stay in oil
    end

    -- Git status per entry. We parse `git status --porcelain --ignored` once per
    -- directory (cached until navigation/edits) and boil it down to two states:
    --   * "changed"   — a tracked file with any modification (modified / added /
    --                   removed / renamed all read the same: one sign, ● )
    --   * "untracked" — untracked or ignored (same thing): no sign, dimmed grey.
    -- A clean tracked file has no state: white name, no sign.
    local status_cache = {}

    local function refresh_status(dir)
      local map = {}
      -- --ignored so gitignored entries (e.g. .DS_Store) count as untracked. A
      -- fully untracked/ignored subdir collapses to "sub/" (a direct entry we
      -- dim); a tracked subdir holding a change shows the nested "sub/file"
      -- path, which we bubble up so the dir itself is marked changed.
      local out = vim.fn.systemlist({ "git", "-C", dir, "status", "--porcelain", "--ignored", "--", "." })
      if vim.v.shell_error == 0 then
        for _, line in ipairs(out) do
          local code = line:sub(1, 2)
          local path = line:sub(4)
          -- staged renames read as "orig -> new"; the new name is what's shown
          path = path:match("%->%s*(.*)$") or path
          local direct = path:match("^([^/]+)/?$")
          if direct then
            map[direct] = (code == "??" or code == "!!") and "untracked" or "changed"
          else
            -- change lives inside a subdir: mark the top dir changed unless it
            -- already carries its own (untracked) status.
            local top = path:match("^([^/]+)/")
            if top and not map[top] then map[top] = "changed" end
          end
        end
      end
      status_cache[dir] = map
    end

    local function git_state(name, dir)
      if not dir then return nil end
      if not status_cache[dir] then refresh_status(dir) end
      return status_cache[dir][name]
    end

    -- Left-gutter column: one sign for a changed tracked file, blank otherwise
    -- (clean tracked and untracked both render blank; untracked is shown by its
    -- dimmed name instead). A plain " " would be rendered as oil's "-" empty
    -- placeholder, so blank rows use a non-breaking space, which oil's
    -- whitespace check treats as real content.
    local NBSP = "\194\160"
    require("oil.columns").register("git", {
      render = function(entry, _conf, bufnr)
        if git_state(entry[FIELD_NAME], oil.get_current_dir(bufnr)) == "changed" then
          return { "●", "OilGitChanged" }
        end
        return NBSP
      end,
      -- Oil round-trips the buffer line back through each column; consume our
      -- single-cell token and hand the rest (the name) to the next column.
      parse = function(line)
        return line:match("^(%S+)%s+(.*)$")
      end,
    })

    -- Dim untracked/ignored names to grey; tracked names stay normal (white).
    -- "hidden" here means "not tracked by git", not "starts with a dot", so
    -- tracked dotfiles render normally.
    local function is_hidden(name, bufnr)
      if name == ".git" then return true end -- keep the git dir out of the way
      return git_state(name, oil.get_current_dir(bufnr)) == "untracked"
    end

    -- Drop the cache on navigation and after edits so status stays fresh.
    local function clear_cache() status_cache = {} end
    vim.api.nvim_create_autocmd("BufEnter", { pattern = "oil://*", callback = clear_cache })
    vim.api.nvim_create_autocmd("User", { pattern = "OilActionsPost", callback = clear_cache })

    -- Sign colour and the dimmed-name colour. `default = true` so a colorscheme
    -- defining these wins; links point at groups every modern theme ships.
    local function set_hl()
      vim.api.nvim_set_hl(0, "OilGitChanged", { link = "DiagnosticWarn", default = true })
      -- Grey out untracked names (oil highlights hidden entries with OilHidden).
      vim.api.nvim_set_hl(0, "OilHidden", { link = "Comment", default = true })
    end
    set_hl()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

    oil.setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      columns = { "git", "icon" },
      view_options = {
        show_hidden = true, -- keep untracked entries visible (just dimmed)
        is_hidden_file = is_hidden,
      },
      float = {
        padding = 2,
        max_width = 100,
        max_height = 30,
        border = "rounded",
      },
      keymaps = {
        ["q"] = close_with_prompt,
        ["<Esc>"] = close_with_prompt,
      },
    })
  end,
}
