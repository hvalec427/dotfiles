#!/usr/bin/env bash

SESSION="dotfiles"
DIR="$HOME/dev/dotfiles"

tmux has-session -t "$SESSION" 2>/dev/null
if [ $? -eq 0 ]; then
  tmux attach -t "$SESSION"
  exit 0
fi

tmux new-session -d -s "$SESSION" -n editor -c "$DIR"
tmux send-keys -t "$SESSION":editor.0 'nvim' C-m

tmux new-window -t "$SESSION" -n claude -c "$DIR"
tmux send-keys -t "$SESSION":claude.0 'claude' C-m

tmux new-window -t "$SESSION" -n shell -c "$DIR"

tmux select-window -t "$SESSION":editor
tmux attach-session -t "$SESSION"
