#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")/" && pwd)"
log() { printf "\n==> %s\n" "$*"; }

log "making scripts executable"
bash "$DIR/zsh/make-scripts-executable.sh"

# ensure brew
if ! command -v brew >/dev/null; then
  log "installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || \
eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true

# install brewfiles
log "installing brewfiles"

BREWFILE="$DIR/Brewfile"
if [ -f "$BREWFILE" ]; then
  log "brew bundle: main Brewfile"
  brew bundle --file "$BREWFILE" --verbose
else
  log "no Brewfile found at $BREWFILE"
fi
log "done installing brewfiles"

# collect stow packages
log "stowing configs"

PACKAGES=()
for d in "$DIR"/config/*; do
  [ -d "$d" ] || continue
  pkg="$(basename "$d")"
  case "$pkg" in
    .* )
      continue
      ;;
  esac
  PACKAGES+=("$pkg")
done

if [ ${#PACKAGES[@]} -eq 0 ]; then
  log "no config packages found"
else
  command -v stow >/dev/null || { log "installing stow"; brew install stow; }

  cd "$DIR"
  for pkg in "${PACKAGES[@]}"; do
    log "stowing: $pkg"
    stow -d config -t ~ "$pkg"
  done
fi
log "done stowing configs"

# install repos and extras
log "installing repos"
install_repos() {
  local repo_file="$DIR/repos/repos.txt"
  [ -f "$repo_file" ] || return

  command -v git >/dev/null || { log "git missing; cannot install repos"; return; }

  log "installing repos from ${repo_file#$DIR/}"
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

install_repos
log "done installing repos"

log "adding zsh aliases"
alias_file="$DIR/zsh/common.zsh"
zshrc="$HOME/.zshrc"
start_line="if [ -f \"$alias_file\" ]; then"

if [ -f "$alias_file" ]; then
  touch "$zshrc"
  if ! grep -Fq "$start_line" "$zshrc" 2>/dev/null; then
    {
      printf "%s\n" "$start_line"
      printf "  source \"%s\"\n" "$alias_file"
      printf "fi\n"
    } >> "$zshrc"
    log "applied zsh block for $alias_file"
  fi
else
  log "$alias_file missing; skipping aliases"
fi

log "bootstrap complete"

private_installer="$DIR/private/install.sh"
if [ -f "$private_installer" ]; then
  chmod +x "$private_installer"
  log "running private installer"
  "$private_installer"
  log "done installing private installer"
fi
source ~/.zshrc
