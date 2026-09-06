#!/usr/bin/env bash
#
# Bootstrap the custom tmux-fingers fork (adds @fingers-mnemonic-hints).
#
# On any machine this makes sure a working `tmux-fingers` binary exists and then
# loads the config. It prefers a prebuilt binary from the fork's GitHub
# Releases (no toolchain needed) and only falls back to building from source
# with crystal/shards. It is idempotent: once the binary exists, later runs just
# call `load-config`. The binary is invoked by absolute path, so a Homebrew
# `tmux-fingers` on PATH does not shadow it.

set -e

# Make brew-installed tools (curl/git/crystal/shards) reachable even if tmux
# started with a minimal PATH.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

REPO="hvalec427/tmux-fingers"
FORK_URL="https://github.com/$REPO"
FORK_BRANCH="mnemonic-hints"

BASE="${TMUX_PLUGIN_MANAGER_PATH:-$HOME/.config/tmux/plugins/}"
FINGERS_DIR="${BASE%/}/tmux-fingers"
BIN="$FINGERS_DIR/bin/tmux-fingers"

# Release asset name for this platform (matches the CI workflow's artifacts).
case "$(uname -s)/$(uname -m)" in
  Darwin/arm64) SUFFIX="macos-arm64" ;;
  Linux/x86_64) SUFFIX="linux-x86_64" ;;
  *) SUFFIX="" ;;
esac

download_binary() {
  [ -n "$SUFFIX" ] || return 1
  command -v curl >/dev/null 2>&1 || return 1

  local url
  url=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" |
    grep browser_download_url | grep "$SUFFIX" | cut -d'"' -f4 | head -1)
  [ -n "$url" ] || return 1

  mkdir -p "$(dirname "$BIN")"
  curl -fL "$url" -o "$BIN.tmp" && chmod +x "$BIN.tmp" && mv "$BIN.tmp" "$BIN"
}

build_from_source() {
  command -v shards >/dev/null 2>&1 || return 1

  if [ ! -d "$FINGERS_DIR/.git" ] ||
    ! git -C "$FINGERS_DIR" remote get-url origin 2>/dev/null | grep -q "$REPO"; then
    rm -rf "$FINGERS_DIR"
    git clone -b "$FORK_BRANCH" "$FORK_URL" "$FINGERS_DIR"
  fi
  (cd "$FINGERS_DIR" && shards install && shards build --release)
}

if [ ! -x "$BIN" ]; then
  download_binary || build_from_source || {
    tmux display-message "tmux-fingers: couldn't download or build the mnemonic-hints binary"
    exit 0
  }
fi

exec "$BIN" load-config
