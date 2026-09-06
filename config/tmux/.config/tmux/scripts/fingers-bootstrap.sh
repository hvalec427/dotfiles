#!/usr/bin/env bash
#
# Bootstrap the custom tmux-fingers fork (adds @fingers-mnemonic-hints).
#
# Downloads a prebuilt binary from the fork's GitHub releases and loads the
# config. It never builds from source. Idempotent: once the binary exists, later
# runs just call `load-config`. The binary is invoked by absolute path, so a
# Homebrew `tmux-fingers` on PATH does not shadow it.

set -e

# Make brew-installed curl reachable even if tmux started with a minimal PATH.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

REPO="hvalec427/tmux-fingers"

BASE="${TMUX_PLUGIN_MANAGER_PATH:-$HOME/.config/tmux/plugins/}"
FINGERS_DIR="${BASE%/}/tmux-fingers"
BIN="$FINGERS_DIR/bin/tmux-fingers"

# Release asset name for this platform (matches the CI workflow's artifacts).
case "$(uname -s)/$(uname -m)" in
  Darwin/arm64) SUFFIX="macos-arm64" ;;
  Linux/x86_64) SUFFIX="linux-x86_64" ;;
  *) SUFFIX="" ;;
esac

if [ ! -x "$BIN" ]; then
  if [ -z "$SUFFIX" ]; then
    tmux display-message "tmux-fingers: no prebuilt binary for $(uname -s)/$(uname -m)"
    exit 0
  fi

  url=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" |
    grep browser_download_url | grep "$SUFFIX" | cut -d'"' -f4 | head -1)
  if [ -z "$url" ]; then
    tmux display-message "tmux-fingers: could not find a $SUFFIX release asset"
    exit 0
  fi

  mkdir -p "$(dirname "$BIN")"
  curl -fL "$url" -o "$BIN.tmp" && chmod +x "$BIN.tmp" && mv "$BIN.tmp" "$BIN"
fi

exec "$BIN" load-config
