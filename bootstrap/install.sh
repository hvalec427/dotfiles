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
  items=("all" "none" "$@")

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
      log "select at least one option with space or choose 'none' or 'all'"
      continue
    fi

    if printf "%s\n" "$choice" | grep -qx "none"; then
      echo ""
      return
    fi

    if printf "%s\n" "$choice" | grep -qx "all"; then
      printf "%s\n" "$@"
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
ESSENTIAL_BREWFILE=""
for f in "$DIR"/brewfiles/Brewfile.*; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  prof="${base#Brewfile.}"
  if [ "$prof" = "essentials" ]; then
    ESSENTIAL_BREWFILE="$f"
    continue
  fi
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

if [ -n "$SELECTED_PROFILES" ]; then
  printf "\n==> selected profiles:\n%s\n" "$SELECTED_PROFILES"
else
  log "no profiles selected"
fi

log "select configs to symlink"
SELECTED_PKGS="$(choose_required "Configs (space to toggle, enter to confirm)" "${PACKAGES[@]}")"

if [ -n "$SELECTED_PKGS" ]; then
  printf "\n==> selected configs:\n%s\n" "$SELECTED_PKGS"
else
  log "no configs selected"
fi

# ensure essentials are always installed
if [ -n "$ESSENTIAL_BREWFILE" ]; then
  log "brew bundle: essentials"
  brew bundle --file "$ESSENTIAL_BREWFILE" --verbose
fi

# run brew only if selected
install_tpm_if_needed() {
  local target="$HOME/.tmux/plugins/tpm"
  if [ -d "$target" ]; then
    log "tpm already installed"
    return
  fi

  command -v git >/dev/null || { log "git missing; cannot install tpm"; return; }

  log "installing tpm"
  git clone https://github.com/tmux-plugins/tpm "$target"
}

install_repos_for_profile() {
  local profile="$1"
  local repo_file="$DIR/repos/$profile/repos.txt"
  [ -f "$repo_file" ] || return

  command -v git >/dev/null || { log "git missing; cannot install repos for $profile"; return; }

  log "installing repos for $profile"
  grep '^repo ' "$repo_file" | while read -r _ repo _ path; do
    local dir="${path/#\~/$HOME}"
    if [ -d "$dir" ]; then
      log "$dir already exists"
      continue
    fi

    log "Cloning $repo → $dir"
    mkdir -p "$(dirname "$dir")"
    git clone "$repo" "$dir"
  done
}

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
    if [ "$profile" = "coding" ]; then
      install_tpm_if_needed
    fi
    if [ "$profile" = "coding" ] || [ "$profile" = "personal" ]; then
      install_repos_for_profile "$profile"
    fi
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
