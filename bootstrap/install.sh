#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)"
log() { printf "\n==> %s\n" "$*"; }

# ensure brew
if ! command -v brew >/dev/null; then
  log "installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || \
eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true

# ensure gum
if ! command -v gum >/dev/null; then
  log "installing gum"
  brew install gum
fi

choose_required() {
  title="$1"; shift
  items=("none" "$@")

  while :; do
    set +e
    choice="$(printf "%s\n" "${items[@]}" | \
      gum choose \
        --no-limit \
        --height 12 \
        --header "$title" \
        --show-help=false)"
    status=$?
    set -e

    # cancelled
    if [ $status -ne 0 ]; then
      log "cancelled"
      exit 130
    fi

    # trim whitespace
    choice="$(printf "%s" "$choice" | sed '/^\s*$/d')"

    if [ -z "$choice" ]; then
      log "select at least one option with space or choose 'none'"
      continue
    fi

    if printf "%s\n" "$choice" | grep -qx "none"; then
      echo ""
      return
    fi

    printf "%s\n" "$choice"
    return
  done
}

apply_zsh_aliases() {
  local zshrc="$HOME/.zshrc"
  local alias_file="$DIR/zsh/common.zsh"
  local start_line="if [ -f \"$alias_file\" ]; then"
  local end_line="fi"

  [ -f "$alias_file" ] || return
  touch "$zshrc"

  if grep -Fq "$start_line" "$zshrc" 2>/dev/null; then
    tmpfile="$(mktemp)"
    awk -v start="$start_line" -v end="$end_line" 'BEGIN {skip=0}
      {
        if (skip) {
          if ($0 == end) {
            skip=0
          }
          next
        }
        if ($0 == start) {
          skip=1
          next
        }
        print
      }
    ' "$zshrc" > "$tmpfile"
    mv "$tmpfile" "$zshrc"
  fi

  if ! grep -Fq "$start_line" "$zshrc" 2>/dev/null; then
    {
      printf "if [ -f \"%s\" ]; then\n" "$alias_file"
      printf "  source \"%s\"\n" "$alias_file"
      printf "fi\n"
    } >> "$zshrc"
    log "applied zsh block to $zshrc"
  fi
}

# collect brewfiles
BREWFILES=()
BREWFILE_PATHS=()
for f in "$DIR"/Brewfiles/Brewfile.*; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  prof="${base#Brewfile.}"
  BREWFILES+=("$prof")
  BREWFILE_PATHS+=("$f")
done

# collect stow packages
PACKAGES=()
for d in "$DIR"/config/*; do
  [ -d "$d" ] || continue
  PACKAGES+=("$(basename "$d")")
done

# TUI first
log "select brew profiles"
SELECTED_PROFILES="$(choose_required "Profiles (space to toggle, enter to confirm)" "${BREWFILES[@]}")"

log "select configs to symlink"
SELECTED_PKGS="$(choose_required "Configs (space to toggle, enter to confirm)" "${PACKAGES[@]}")"

# run brew only if selected
if [ -n "$SELECTED_PROFILES" ]; then
  for profile in $SELECTED_PROFILES; do
    found=""
    i=0
    while [ $i -lt ${#BREWFILES[@]} ]; do
      if [ "${BREWFILES[$i]}" = "$profile" ]; then
        found="${BREWFILE_PATHS[$i]}"
        break
      fi
      i=$((i+1))
    done

    if [ -z "$found" ] || [ ! -f "$found" ]; then
      log "missing Brewfile for profile: $profile"
      exit 1
    fi

    log "brew bundle: $profile"
    brew bundle --file "$found" --verbose
  done
fi

# stow if selected
if [ -n "$SELECTED_PKGS" ]; then
  command -v stow >/dev/null || { log "installing stow"; brew install stow; }

  cd "$DIR"
  for pkg in $SELECTED_PKGS; do
    log "stowing: $pkg"
    stow -d config -t ~ "$pkg"
  done
fi

apply_zsh_aliases

log "bootstrap complete"
