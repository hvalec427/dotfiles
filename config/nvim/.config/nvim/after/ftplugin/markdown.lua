-- Neovim's bundled markdown parser crashes the core highlighter on files
-- with nested fenced code blocks; core's own ftplugin documents this as the
-- correct way to undo its vim.treesitter.start() call.
vim.treesitter.stop()
