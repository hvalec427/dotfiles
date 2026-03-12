#!/usr/bin/env bash
set -euo pipefail

if [[ "${DEBUG:-0}" == "1" ]]; then
  set -x
fi

SESSION="laundryheap-runners"
RUN_BE=false
RUN_FLEET=false
RUN_WEBAPP=false
RESET=false

print_help() {
  cat << EOF
Usage: $0 [options]

Options:
  -b           Run backend
  -f           Run fleet
  -w           Run webapp
  -a           Run all (backend, fleet, webapp)
  --reset      Run git reset --hard before starting each selected service
  -h, --help   Display this help message

Behavior:
  Runs each selected service in its own tmux window inside session: $SESSION
  Backend window also opens a second pane for Sidekiq.
  Does not open Terminal.app or iTerm windows.

Examples:
  $0 -b            # Run only backend
  $0 -a --reset    # Run all with reset
  $0 -w -f         # Run webapp and fleet
EOF
}

print_error_usage() {
  local message="$1"
  echo "Error: $message" >&2
  echo >&2
  echo "Run '$0 --help' to see all options." >&2
  echo "Quick usage: $0 [-b] [-f] [-w] [-a] [--reset]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -b) RUN_BE=true ;;
    -f) RUN_FLEET=true ;;
    -w) RUN_WEBAPP=true ;;
    -a)
      RUN_BE=true
      RUN_FLEET=true
      RUN_WEBAPP=true
      ;;
    --reset) RESET=true ;;
    -h|--help)
      print_help
      exit 0
      ;;
    *)
      print_error_usage "Unknown option '$1'."
      exit 1
      ;;
  esac
  shift
done

if ! $RUN_BE && ! $RUN_FLEET && ! $RUN_WEBAPP; then
  print_error_usage "No service selected."
  echo "Pick at least one: -b (backend), -f (fleet), -w (webapp), or -a (all)." >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BE_DIR="$HOME/dev/LaundryHeap-BE"
FLEET_DIR="$HOME/dev/laundryHeap-fleet"
WEBAPP_DIR="$HOME/dev/laundryHeap-webapp"

if $RUN_BE; then
  [ -d "$BE_DIR" ] || { echo "Missing directory: $BE_DIR" >&2; exit 1; }
fi
if $RUN_FLEET; then
  [ -d "$FLEET_DIR" ] || { echo "Missing directory: $FLEET_DIR" >&2; exit 1; }
fi
if $RUN_WEBAPP; then
  [ -d "$WEBAPP_DIR" ] || { echo "Missing directory: $WEBAPP_DIR" >&2; exit 1; }
fi

RESET_CMD=""
$RESET && RESET_CMD="git reset --hard &&"

SESSION_EXISTS=1
if tmux has-session -t "$SESSION" >/dev/null 2>&1; then
  SESSION_EXISTS=0
fi

start_window() {
  local window_name="$1"
  local command="$2"
  local workdir="$3"
  local target="$SESSION:$window_name.0"
  local existing
  local pane_cmd
  existing=$(tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -Fx "$window_name" || true)

  if [ -z "$existing" ]; then
    tmux new-window -d -t "$SESSION" -n "$window_name" -c "$workdir"
    tmux send-keys -t "$target" "$command" C-m
    return
  fi

  pane_cmd=$(tmux display-message -p -t "$target" '#{pane_current_command}' 2>/dev/null)
  if [ "$pane_cmd" = "bash" ] || [ "$pane_cmd" = "zsh" ] || [ "$pane_cmd" = "sh" ]; then
    tmux send-keys -t "$target" "$command" C-m
  fi
}

start_backend() {
  local window_name="backend"
  local target_window="$SESSION:$window_name"
  local rails_target="$target_window.0"
  local sidekiq_target="$target_window.1"
  local existing
  local pane_cmd
  local pane_count

  existing=$(tmux list-windows -t "$SESSION" -F '#{window_name}' | grep -Fx "$window_name" || true)
  if [ "$SESSION_EXISTS" -ne 0 ]; then
    tmux new-session -d -s "$SESSION" -n "$window_name" -c "$BE_DIR"
    SESSION_EXISTS=0
  elif [ -z "$existing" ]; then
    tmux new-window -d -t "$SESSION" -n "$window_name" -c "$BE_DIR"
  fi

  pane_cmd=$(tmux display-message -p -t "$rails_target" '#{pane_current_command}' 2>/dev/null)
  if [ "$pane_cmd" = "bash" ] || [ "$pane_cmd" = "zsh" ] || [ "$pane_cmd" = "sh" ]; then
    tmux send-keys -t "$rails_target" "$RAILS_CMD" C-m
  fi

  pane_count=$(tmux list-panes -t "$target_window" | wc -l | tr -d ' ')
  if [ "$pane_count" -lt 2 ]; then
    tmux split-window -h -t "$rails_target" -c "$BE_DIR"
    tmux select-layout -t "$target_window" main-vertical
  fi

  pane_cmd=$(tmux display-message -p -t "$sidekiq_target" '#{pane_current_command}' 2>/dev/null)
  if [ "$pane_cmd" = "bash" ] || [ "$pane_cmd" = "zsh" ] || [ "$pane_cmd" = "sh" ]; then
    tmux send-keys -t "$sidekiq_target" "$SIDEKIQ_CMD" C-m
  fi
}

create_or_start_window() {
  local window_name="$1"
  local command="$2"
  local workdir="$3"

  if [ "$SESSION_EXISTS" -ne 0 ]; then
    tmux new-session -d -s "$SESSION" -n "$window_name" -c "$workdir"
    tmux send-keys -t "$SESSION:$window_name.0" "$command" C-m
    SESSION_EXISTS=0
    return
  fi

  start_window "$window_name" "$command" "$workdir"
}

RAILS_CMD="cd \"$BE_DIR\" && $RESET_CMD git pull || true; bundle check || bundle install; bin/rails db:migrate; exec rails s -b 0.0.0.0 -p 3000"
SIDEKIQ_CMD="cd \"$BE_DIR\" && exec bundle exec sidekiq"
FLEET_CMD="cd \"$FLEET_DIR\" && $RESET_CMD git pull || true; if [ -f package-lock.json ]; then npm ci; else npm i; fi; exec npm run dev"
WEBAPP_CMD="cd \"$WEBAPP_DIR\" && $RESET_CMD git pull || true; exec npm run dev"

declare -a WINDOWS=()
$RUN_BE && WINDOWS+=("backend") && start_backend
$RUN_FLEET && WINDOWS+=("fleet") && create_or_start_window "fleet" "$FLEET_CMD" "$FLEET_DIR"
$RUN_WEBAPP && WINDOWS+=("webapp") && create_or_start_window "webapp" "$WEBAPP_CMD" "$WEBAPP_DIR"

tmux select-window -t "$SESSION":"${WINDOWS[0]}"
tmux select-pane -t "$SESSION":"${WINDOWS[0]}".0
tmux attach-session -c "$SCRIPT_DIR" -t "$SESSION"
