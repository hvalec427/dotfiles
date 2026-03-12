#!/usr/bin/env bash

SESSION="laundryheapp-driverapp"
DIR="$HOME/dev/laundryheap-driver-app"

resize_main_pane() {
  local width target
  width="$(tmux display-message -p -t "$SESSION":main '#{window_width}' 2>/dev/null)"
  if [ -n "$width" ]; then
    target=$((width * 80 / 100))
    if [ "$target" -lt 1 ]; then
      target=1
    fi
    tmux resize-pane -t "$SESSION":main.0 -x "$target"
  fi
}

cd "$DIR" || {
  echo "Directory not found: $DIR" >&2
  exit 1
}

tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  RIGHT_CMD=$(tmux display-message -p -t "$SESSION":main.2 '#{pane_current_command}' 2>/dev/null)
  if [ "$RIGHT_CMD" != "yarn" ] && [ "$RIGHT_CMD" != "node" ]; then
    tmux send-keys -t "$SESSION":main.2 'yarn start' C-m
  fi
  tmux select-window -t "$SESSION":main
  tmux select-pane -t "$SESSION":main.0
  resize_main_pane
  tmux attach-session -c "$DIR" -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION" -n main -c "$DIR"
tmux send-keys -t "$SESSION":main.0 'nvim' C-m

# split right side
tmux split-window -h -t "$SESSION":main.0 -c "$DIR"
tmux send-keys -t "$SESSION":main.1 'htop' C-m

tmux split-window -v -t "$SESSION":main.1 -c "$DIR"
tmux send-keys -t "$SESSION":main.2 'yarn start' C-m

# make left pane larger and stack smaller panes on the right
tmux select-layout -t "$SESSION":main main-vertical
resize_main_pane

tmux new-window -t "$SESSION" -n copilot -c "$DIR"
tmux send-keys -t "$SESSION":copilot.0 'copilot' C-m

tmux new-window -t "$SESSION" -n terminal -c "$DIR"

tmux select-window -t "$SESSION":main
tmux select-pane -t "$SESSION":main.0
tmux attach-session -c "$DIR" -t "$SESSION"
