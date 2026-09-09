return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    init = function()
      vim.g.tmux_navigator_no_wrap = 1
    end,
  },
  {
    -- tmux-like directional window resizing: <C-w>h/j/k/l always move the
    -- border in that physical direction, correct in any split layout.
    "mrjones2014/smart-splits.nvim",
    keys = {
      { "<C-w>h", function() require("smart-splits").resize_left(15) end, desc = "Resize split left" },
      { "<C-w>l", function() require("smart-splits").resize_right(15) end, desc = "Resize split right" },
      { "<C-w>j", function() require("smart-splits").resize_down(5) end, desc = "Resize split down" },
      { "<C-w>k", function() require("smart-splits").resize_up(5) end, desc = "Resize split up" },
    },
    opts = {},
  },
}
