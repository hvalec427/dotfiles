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
      close               = '<Esc>',
      select              = '<CR>',
      select_split        = '<C-s>',
      select_vsplit       = '<C-v>',
      move_down           = { '<C-n>', '<Down>', '<Tab>' },
      move_up             = { '<C-p>', '<Up>' },
      preview_scroll_up   = '<C-u>',
      preview_scroll_down = '<C-d>',
      cycle_grep_modes    = '<S-Tab>',
      toggle_select       = {},
    },
  },
}
