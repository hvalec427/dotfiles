#!/usr/bin/env bash

SESSION="laundryheapp-driverapp"
DIR="$HOME/dev/laundryheapp-driverapp"

tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION" -n main -c "$DIR"
tmux send-keys -t "$SESSION":main.0 'nvim' C-m

# split right side
tmux split-window -h -t "$SESSION":main.0 -c "$DIR"
tmux send-keys -t "$SESSION":main.1 'yarn start' C-m

# make left pane larger
tmux select-layout -t "$SESSION":main main-vertical

tmux new-window -t "$SESSION" -n codex -c "$DIR"
tmux send-keys -t "$SESSION":codex.0 'codex' C-m

tmux new-window -t "$SESSION" -n terminal -c "$DIR"

tmux select-pane -t "$SESSION":main.0
tmux attach-session -t "$SESSION"
