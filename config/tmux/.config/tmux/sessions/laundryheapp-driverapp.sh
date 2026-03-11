#!/usr/bin/env bash

SESSION="laundryheapp-driverapp"
DIR="$HOME/dev/laundryheap-driver-app"

cd "$DIR" || {
  echo "Directory not found: $DIR" >&2
  exit 1
}

tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  RIGHT_CMD=$(tmux display-message -p -t "$SESSION":main.1 '#{pane_current_command}' 2>/dev/null)
  if [ "$RIGHT_CMD" != "yarn" ] && [ "$RIGHT_CMD" != "node" ]; then
    tmux send-keys -t "$SESSION":main.1 'yarn start' C-m
  fi
  tmux select-window -t "$SESSION":main
  tmux select-pane -t "$SESSION":main.0
  tmux attach-session -c "$DIR" -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION" -n main -c "$DIR"
tmux send-keys -t "$SESSION":main.0 'nvim' C-m

# split right side
tmux split-window -h -t "$SESSION":main.0 -c "$DIR"
tmux send-keys -t "$SESSION":main.1 'yarn start' C-m

# make left pane larger
tmux select-layout -t "$SESSION":main main-vertical

tmux new-window -t "$SESSION" -n copilot -c "$DIR"
tmux send-keys -t "$SESSION":copilot.0 'copilot' C-m

tmux new-window -t "$SESSION" -n terminal -c "$DIR"

tmux select-window -t "$SESSION":main
tmux select-pane -t "$SESSION":main.0
tmux attach-session -c "$DIR" -t "$SESSION"
