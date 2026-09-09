#!/usr/bin/env bash
set -uo pipefail

DEV="$HOME/dev"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

dot() {
  if grep -qxF "$1" <<<"$RUNNING"; then printf '\033[32m●\033[0m'; else printf '\033[38;5;240m○\033[0m'; fi
}

emit_list() {
  local predefined name dir base line running idle
  predefined="$(tmuxinator list -n 2>/dev/null | tail -n +2)"
  RUNNING="$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"
  running=""
  idle=""

  add() {
    if grep -qxF "$1" <<<"$RUNNING"; then running+="$2"$'\n'; else idle+="$2"$'\n'; fi
  }

  while IFS= read -r name; do
    [ -n "$name" ] || continue
    line="$(printf '%s \033[33m\033[0m  %s\t%s\t%s' "$(dot "$name")" "$name" "$name" "$name")"
    add "$name" "$line"
  done <<<"$predefined"

  while IFS= read -r dir; do
    base="${dir##*/}"
    grep -qxF "$base" <<<"$predefined" && continue
    line="$(printf '%s \033[34m\033[0m  %s\t%s\t%s' "$(dot "$base")" "$base" "$dir" "$base")"
    add "$base" "$line"
  done < <(find "$DEV" -mindepth 1 -maxdepth 1 -type d ! -name node_modules | sort)

  printf '%s' "$running"
  printf '%s' "$idle"
}

if [ "${1:-}" = "--list" ]; then
  emit_list
  exit 0
fi

choice="$(emit_list | fzf \
  --ansi --layout=reverse --delimiter='\t' --with-nth=1 \
  --border-label ' sessions ' --prompt '  ' \
  --header '● running  ○ idle   ·   enter connect  ·  ^d kill  ·  tab/⇧tab move' --header-first \
  --bind 'tab:down,btab:up' \
  --bind "ctrl-d:execute-silent(tmux kill-session -t {3} 2>/dev/null)+reload($SELF --list)" \
  --preview-window 'right:55%' \
  --preview 'f={2}; if [ -d "$f" ]; then
      eza -la --git --group-directories-first --color=always "$f" 2>/dev/null || ls -la "$f";
      echo; git -C "$f" log --oneline -8 2>/dev/null;
    else sesh preview "$f"; fi')"

[ -n "$choice" ] || exit 0

token="$(printf '%s' "$choice" | cut -f2)"
if [ -d "$token" ]; then sesh connect "$token"; else sesh connect -T "$token"; fi
