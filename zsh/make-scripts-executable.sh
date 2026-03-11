#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

TARGET_FILES=(
  "$REPO_ROOT/bootstrap/install.sh"
  "$REPO_ROOT/zsh/make-scripts-executable.sh"
  "$REPO_ROOT/config/tmux/.config/tmux/sessions/zigahvalec.sh"
  "$REPO_ROOT/config/tmux/.config/tmux/sessions/laundryheap-mobile.sh"
  "$REPO_ROOT/config/tmux/.config/tmux/sessions/laundryheapp-driverapp.sh"
  "$REPO_ROOT/config/tmux/.config/tmux/sessions/laundryheap-runners.sh"
)

changed=0
missing=0

for file in "${TARGET_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "Missing (skipped): $file"
    missing=$((missing + 1))
    continue
  fi

  chmod +x "$file"
  changed=$((changed + 1))
done

echo "Made executable: $changed script(s)."
echo "Missing: $missing file(s)."
