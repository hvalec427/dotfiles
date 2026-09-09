#!/usr/bin/env bash
# Focus the Claude Code pane if one is already open in the current session,
# otherwise open it in a right-hand split of the current pane's dir.
set -euo pipefail

target=$(tmux list-panes -s -F '#{pane_current_command} #{window_id} #{pane_id}' \
  | awk '$1 == "claude" { print $2, $3; exit }')

if [ -n "$target" ]; then
  window=${target% *}
  pane=${target#* }
  tmux select-window -t "$window"
  tmux select-pane -t "$pane"
else
  tmux split-window -fh -l 40% -c "#{pane_current_path}" "claude"
fi
