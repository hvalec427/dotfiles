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
      move_down     = { '<Down>', '<C-n>', '<Tab>' },
      move_up       = { '<Up>', '<C-p>', '<S-Tab>' },
      toggle_select    = '<F13>',
      cycle_grep_modes = '<F14>',
    },
  },
}
