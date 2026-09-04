return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      current_line_blame = true,
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]c", function()
          if vim.wo.diff then
            return "]c"
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Next hunk" })

        map("n", "[c", function()
          if vim.wo.diff then
            return "[c"
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return "<Ignore>"
        end, { expr = true, desc = "Prev hunk" })

        -- Hunk actions
        map("n", "<leader>hs", gs.stage_hunk, { desc = "[h]unk [s]tage" })
        map("n", "<leader>hr", gs.reset_hunk, { desc = "[h]unk [r]eset" })
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[h]unk [s]tage (selection)" })
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "[h]unk [r]eset (selection)" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "[h]unk [S]tage buffer" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "[h]unk [R]eset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "[h]unk [p]review" })
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, { desc = "[h]unk [b]lame line" })
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      enhanced_diff_hl = true,
      use_icons = true,
    },
  },
}
