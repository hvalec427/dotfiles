#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "$0")/.." && pwd)"

log() { printf "\n==> %s\n" "$*"; }

# ensure homebrew
if ! command -v brew >/dev/null; then
  log "installing homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ensure brew in PATH (apple silicon + intel safe)
eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || \
eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null || true

# ensure gum BEFORE any UI
if ! command -v gum >/dev/null; then
  log "installing gum"
  brew install gum
fi

# collect brew profiles
BREWFILES=()
for f in "$DIR"/Brewfiles/Brewfile.*; do
  [ -e "$f" ] || continue
  name=$(basename "$f")
  BREWFILES+=("${name#Brewfile.}")
done

# collect stow packages
PACKAGES=()
for d in "$DIR"/config/*; do
  [ -d "$d" ] || continue
  PACKAGES+=("$(basename "$d")")
done

log "select brew profiles"
SELECTED_PROFILES="$(printf "%s\n" "${BREWFILES[@]}" | gum choose --no-limit --height 12)"

log "select configs to symlink"
SELECTED_PKGS="$(printf "%s\n" "${PACKAGES[@]}" | gum choose --no-limit --height 12)"

# run brew bundles
for profile in $SELECTED_PROFILES; do
  log "brew bundle: $profile"
  brew bundle --file "$DIR/Brewfiles/Brewfile.$profile"
done

# ensure stow
command -v stow >/dev/null || brew install stow

cd "$DIR"
for pkg in $SELECTED_PKGS; do
  log "stowing: $pkg"
  stow -d config -t ~ "$pkg"
done

log "done"