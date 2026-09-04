# I'm stupid and I forgot my keymaps

## tmux — layouts

| Key | Layout |
|-----|--------|
| `prefix` `Alt-1` | even-horizontal (side by side) |
| `prefix` `Alt-2` | even-vertical (stacked) |
| `prefix` `Alt-3` | main-horizontal (big pane on top) |
| `prefix` `Alt-4` | main-vertical (big pane on left) |
| `prefix` `Alt-5` | tiled (grid) |
| `prefix` `Space` | cycle through layouts |

Big pane size = `main-pane-width 80%`. Mirror a layout: focus the pane you want big, then `prefix` `Alt-4`.

## tmux — moving panes around

| Key | Action |
|-----|--------|
| `prefix` `}` | swap with next pane |
| `prefix` `{` | swap with prev pane |
| `prefix` `Ctrl-o` | rotate panes |

## tmux — resizing panes

| Key | Action |
|-----|--------|
| `prefix` `H` | resize left (repeatable) |
| `prefix` `J` | resize down (repeatable) |
| `prefix` `K` | resize up (repeatable) |
| `prefix` `L` | resize right (repeatable) |

## tmux — splits & windows

| Key | Action |
|-----|--------|
| `prefix` `"` | split **horizontally** — new pane below (stacked) |
| `prefix` `%` | split **vertically** — new pane to the right (side by side) |
| `prefix` `c` | new window |
| `Alt-Shift-h` | prev window |
| `Alt-Shift-l` | next window |
| `prefix` `s` | session picker (sesh) |

New panes open in the current pane's directory.

## tmux — closing panes & windows

| Key | Action |
|-----|--------|
| `prefix` `x` | kill current **pane** (confirm) |
| `prefix` `&` | kill current **window** (confirm) |

## nvim — splits

| Key | Action |
|-----|--------|
| `Ctrl-w` `s` | split **horizontally** — new window below (stacked) |
| `Ctrl-w` `v` | split **vertically** — new window to the right (side by side) |
| `Ctrl-w` `+` / `-` | resize height |
| `Ctrl-w` `>` / `<` | resize width |

## nvim — closing splits & buffers

| Key | Action |
|-----|--------|
| `Ctrl-w` `q` | close current split |
| `Ctrl-w` `o` | close all other panes |
