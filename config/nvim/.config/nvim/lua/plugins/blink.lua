return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  -- Use a release tag so the prebuilt Rust fuzzy-matcher binary is fetched
  -- (no local `cargo build` needed).
  version = "1.*",
  opts = {
    -- Keymap: keep the pre-blink muscle memory.
    --   Tab / S-Tab   navigate the menu
    --   C-y / CR      accept the selection
    --   C-space       open the menu / toggle docs
    -- `fallback` runs the normal key when the menu isn't visible.
    keymap = {
      preset = "default",
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<C-y>"] = { "accept", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },

    completion = {
      -- Fuzzy as-you-type menu (this is what was missing with native completion).
      menu = { auto_show = true },
      -- Resolve additionalTextEdits (auto-imports) and show docs on select.
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      -- vtsls returns un-imported symbols as auto-import candidates; surface them.
      list = { selection = { preselect = false, auto_insert = false } },
    },

    -- Restore the merged sources lost when the nvim-cmp stack was removed.
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Rust matcher with prebuilt binary; Lua fallback if it can't load.
    fuzzy = { implementation = "prefer_rust_with_warning" },

    -- Snippets via Neovim's built-in vim.snippet (0.10+), no LuaSnip needed.
    snippets = { preset = "default" },

    signature = { enabled = true },
  },
  opts_extend = { "sources.default" },
}
