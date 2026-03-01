# Neovim Config

Personal, Lua-first Neovim configuration that keeps my editing environment identical on every machine. It sets sensible defaults (indentation, search, numbers, clipboard), applies a small set of opinionated keymaps, and wires up the tooling I rely on for coding, writing, and navigating large repositories.

## Project Layout

- `init.lua` is the single entry point. It sets options, defines autocommands, bootstraps all external packages, and then loads the Lua modules that actually power the editor.
- `lua/` contains those modules, grouped by concern (UI polish, completion, diagnostics, formatting, navigation helpers, etc.). Editing or adding modules here is the normal way to extend the setup.
- `lazy-lock.json` pins the versions of every downloaded dependency so all machines stay in sync.

## Requirements

- # Neovim 0.9 or newer.

  Modal Navigation

- h left
- j down
- k up
- l right

## Installation

1. Clone this repo to `~/.config/nvim`: `git clone <repo-url> ~/.config/nvim`.
2. Start Neovim. The first run installs every required dependency automatically; let it finish and restart once if prompted.
3. To update later, pull the latest changes in this directory and restart Neovim.

Insert Lines

- O new line above
- o new line below

Searching in file

- /query
- \c case insensitive
- \C case sensitive
- :%s@search@replace@gc

Selections

- v characterwise
- V linewise
- Ctrl+v blockwise

Copy / Cut / Paste

- y yank
- yy yank line

- d delete
- dd delete line

- P paste before
- p paste after

Swap Lines

- ddp swap with line below
- ddkP swap with line above

Undo / Redo

- u undo
- Ctrl+r redo

Comments

- gcc comment/uncomment
- gc in visual mode

Windows (Splits)

- Ctrl-W + c close window
- Ctrl-W + o close all other windows
- Ctrl-W + s split horizontal
- Ctrl-W + v split vertical
- Ctrl-W + w switch window (up or down)
- Ctrl-W + hjkl switch to left, down, up or right window

Telescope

- <leader>ff find files
- <leader>fg live grep
- <leader>fb file browser

Visual

- "gra" vim.lsp.buf.code_action()
- "an" and "in" outer and inner incremental selections

LSP

- grn Rename
- gra Code Action
- gri Go to Implementation
- grr References
- grt Type Definition

Text manipulation

- ciw change inner word (most common)
- cw change from cursor to end of word
- caw change a word (includes surrounding space)
- diw delete word without insert
- yiw yank word
