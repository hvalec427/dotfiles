return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  lazy = false,
  opts = {
    layout = {
      prompt_position = 'top',
    },
    keymaps = {
      move_down          = { '<C-n>', '<Tab>' },
      move_up            = { '<C-p>', '<S-Tab>' },
      preview_scroll_down = '<Down>',
      preview_scroll_up   = '<Up>',
      toggle_select      = '<F13>',
      cycle_grep_modes   = '<F14>',
    },
  },
}
