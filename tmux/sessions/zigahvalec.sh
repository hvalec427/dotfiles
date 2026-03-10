#!/usr/bin/env bash

SESSION="zigahvalec"
DIR="$HOME/dev/zigahvalec"

tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION" -n main -c "$DIR"
tmux send-keys -t "$SESSION":main.0 'nvim' C-m

# split right side
tmux split-window -h -t "$SESSION":main.0 -c "$DIR"
tmux send-keys -t "$SESSION":main.1 'lazygit' C-m

# split the right pane horizontally
tmux split-window -v -t "$SESSION":main.1 -c "$DIR"
tmux send-keys -t "$SESSION":main.2 'yarn serve' C-m

# make left pane larger
tmux select-layout -t "$SESSION":main main-vertical

tmux select-pane -t "$SESSION":main.0
tmux attach-session -t "$SESSION"
