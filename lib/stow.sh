#!/usr/bin/env bash
# Shared stow helpers used by BOTH the public installer (install.sh) and the
# private one (private/install.sh), so a single set of STOW_<PKG> toggles in
# the repo-root install.conf / install.conf.local governs every package in
# either repo.

# Fallback log() so the lib is usable even if the caller hasn't defined one.
command -v log >/dev/null 2>&1 || log() { printf "\n==> %s\n" "$*"; }

# load_stow_conf <dir>: source install.conf (tracked defaults) then
# install.conf.local (gitignored, machine-specific overrides) from <dir>.
load_stow_conf() {
  local base="$1" conf
  for conf in "$base/install.conf" "$base/install.conf.local"; do
    [ -f "$conf" ] && { log "loading ${conf#"$base"/}"; . "$conf"; }
  done
}

# stow_enabled <pkg>: honors STOW_<PKG> (pkg name uppercased, non-alphanumerics
# -> "_"). Defaults to enabled when the flag is unset.
stow_enabled() {
  local var="STOW_$(printf '%s' "$1" | tr '[:lower:]' '[:upper:]' | tr -c 'A-Z0-9' '_')"
  var="${var%_}"
  case "${!var-}" in
    ""|1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

# stow_all <config_dir> <target>: stow every enabled package in <config_dir>
# into <target>, skipping dotfile dirs and packages disabled via STOW_<PKG>.
stow_all() {
  local config_dir="$1" target="$2" d pkg
  local packages=()

  for d in "$config_dir"/*; do
    [ -d "$d" ] || continue
    pkg="$(basename "$d")"
    case "$pkg" in .*) continue ;; esac
    if ! stow_enabled "$pkg"; then
      log "skipping (disabled): $pkg"
      continue
    fi
    packages+=("$pkg")
  done

  if [ ${#packages[@]} -eq 0 ]; then
    log "no config packages found"
    return
  fi

  command -v stow >/dev/null || { log "installing stow"; brew install stow; }

  # Pre-create ~/.config subdirs so stow links files, not whole directories.
  for d in "$config_dir"/*/.config/*; do
    [ -d "$d" ] || continue
    mkdir -p "$target/.config/$(basename "$d")"
  done

  for pkg in "${packages[@]}"; do
    log "stowing: $pkg"
    stow -d "$config_dir" -t "$target" "$pkg"
  done
}
