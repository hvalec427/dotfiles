#!/usr/bin/env bash
# One-line fresh-machine setup:
#   curl -fsSL https://raw.githubusercontent.com/hvalec427/dotfiles/master/bootstrap.sh | bash
#
# Always clones/pulls the public dotfiles over HTTPS (no SSH key needed). If the
# private repo is reachable over SSH, switches origin to SSH so pushes work;
# otherwise keeps HTTPS so keyless pulls keep working on re-runs. Then runs
# install.sh, which pulls the private submodule (over SSH) when a key is present.
set -euo pipefail

TARGET="$HOME/dev/dotfiles"
HTTPS_URL="https://github.com/hvalec427/dotfiles.git"
SSH_URL="git@github.com:hvalec427/dotfiles.git"
PRIVATE_SSH_URL="git@github.com:hvalec427/private-dotfiles.git"

log() { printf "\n==> %s\n" "$*"; }

command -v git >/dev/null || { echo "git is required but not installed" >&2; exit 1; }

if [ -d "$TARGET/.git" ]; then
  log "dotfiles already at $TARGET; pulling latest"
  git -C "$TARGET" pull --ff-only
else
  log "cloning dotfiles into $TARGET"
  mkdir -p "$(dirname "$TARGET")"
  git clone "$HTTPS_URL" "$TARGET"
fi

# Prefer SSH origin only when the private repo is actually reachable over SSH
# (implies a usable key). BatchMode/timeout keep the probe non-interactive.
if GIT_SSH_COMMAND="ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5" \
     git ls-remote "$PRIVATE_SSH_URL" >/dev/null 2>&1; then
  log "private repo reachable over SSH; using SSH origin"
  git -C "$TARGET" remote set-url origin "$SSH_URL"
else
  log "no SSH access to private repo; keeping HTTPS origin"
  git -C "$TARGET" remote set-url origin "$HTTPS_URL"
fi

log "running installer"
cd "$TARGET"
chmod +x install.sh
./install.sh
