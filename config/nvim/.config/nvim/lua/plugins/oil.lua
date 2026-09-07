return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-mini/mini.icons" },
  lazy = false,
  config = function()
    local oil = require("oil")

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

    -- Treat "hidden" as "not tracked by git" instead of "starts with a dot", so
    -- tracked dotfiles render normally and only untracked/ignored entries are
    -- dimmed. Names per directory, computed once and cached until navigation.
    local untracked = {}

    local function refresh_untracked(dir)
      local set = {}
      -- --ignored so gitignored entries (e.g. .DS_Store) show up too, marked
      -- "!!" alongside untracked "??". A fully-untracked/ignored dir collapses
      -- to "sub/" (one entry we dim); a tracked dir holding a stray entry shows
      -- "sub/file" (nested path we skip, so the dir itself stays normal).
      local out = vim.fn.systemlist({ "git", "-C", dir, "status", "--porcelain", "--ignored", "--", "." })
      if vim.v.shell_error == 0 then
        for _, line in ipairs(out) do
          local status = line:sub(1, 2)
          if status == "??" or status == "!!" then
            -- match a direct entry ("file") or a whole dir ("sub/")
            local name = line:sub(4):match("^([^/]+)/?$")
            if name then set[name] = true end
          end
        end
      end
      untracked[dir] = set
    end

    local function is_untracked(name, bufnr)
      if name == ".git" then return true end -- keep the git dir out of the way
      local dir = oil.get_current_dir(bufnr)
      if not dir then return false end
      if not untracked[dir] then refresh_untracked(dir) end
      return untracked[dir][name] == true
    end

    -- Drop the cache on navigation and after edits so status stays fresh.
    local function clear_cache() untracked = {} end
    vim.api.nvim_create_autocmd("BufEnter", { pattern = "oil://*", callback = clear_cache })
    vim.api.nvim_create_autocmd("User", { pattern = "OilActionsPost", callback = clear_cache })

    oil.setup({
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = false,
      view_options = {
        show_hidden = true, -- keep untracked entries visible (just dimmed)
        is_hidden_file = is_untracked,
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
