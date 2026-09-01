return {
  'dmtrKovalenko/fff.nvim',
  build = function()
    require('fff.download').download_or_build_binary()
  end,
  lazy = false,
  init = function()
    local ts_start = vim.treesitter.start
    vim.treesitter.start = function(bufnr, lang)
      if lang == 'markdown' or lang == 'markdown_inline' then
        local ok, name = pcall(vim.api.nvim_buf_get_name, bufnr or 0)
        if ok and name:match('fffile preview$') then return end
      end
      return ts_start(bufnr, lang)
    end
  end,
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
      preview_scroll_up   = 'K',
      preview_scroll_down = 'J',
      cycle_grep_modes    = '<S-Tab>',
      toggle_select       = {},
    },
  },
}
