local file_opts = {
  hidden = true,
  follow = true,
  no_ignore = false, -- respect .gitignore
  fd_opts = "--type f --exclude .git",
  previewer = "builtin",
}

local grep_opts = {
  hidden = true,
  no_ignore = false, -- respect .gitignore
  rg_opts = table.concat({
    "--column",
    "--line-number",
    "--no-heading",
    "--color=always",
    "--smart-case",
    "--glob '!.git/'",
  }, " "),
}

local plugin_spec = {
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      keymap = {
        fzf = {
          ["tab"] = "down",
          ["btab"] = "up",
        },
      },
      winopts = {
        preview = {
          layout = "vertical",
        },
      }
    },
  },
}

return setmetatable(plugin_spec, {
  __index = {
    file_opts = file_opts,
    grep_opts = grep_opts,
  },
})
