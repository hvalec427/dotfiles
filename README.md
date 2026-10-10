# Dotfiles

Welcome to my dotfiles repository. The scripts and configurations here describe a portable macOS development workspace and automate installing tooling, symlinks, and shell helpers for a new machine.

## Overview

A single installer bootstraps Homebrew, installs the `Brewfile`, stows configuration packages from `config/` into `~` / `~/.config`, and adds shared zsh aliases.

## Setup

1. **Clone the repository.** On a fresh Mac, the first `git` asks to install the command line developer tools; accept, then run it again.

   ```sh
   git clone https://github.com/hvalec427/dotfiles.git ~/dev/dotfiles
   cd ~/dev/dotfiles
   ```

2. **Optional:** create `install.conf.local` (see [Per-machine overrides](#per-machine-overrides)). It must exist before the installer runs.

3. **Run `install.sh`** from the repo root:

   ```sh
   ./install.sh
   ```

Re-running the installer is safe; it only reapplies missing symlinks and clones missing repos.

## What the installer does

- Installs Homebrew (if missing) and the `Brewfile`.
- Stows every package in `config/` into `~` / `~/.config`.
- Clones the repos listed in `repos.txt` (e.g. tmux plugin manager).
- Adds a block to `~/.zshrc` that sources `zsh/common.zsh`.

## Per-machine overrides

- `install.conf` holds the **tracked defaults** — every package in `config/` listed with its `STOW_<PKG>` flag, all `true`. Add a line there when you add a package (one without a flag is still stowed).
- `install.conf.local` holds **per-machine overrides** — it is gitignored, loaded after `install.conf`, and overrides it. For example, to keep a machine's own `~/.gitconfig`:

Turning a package off only stops it from being stowed; it doesn't remove links that already exist.
To remove them, run once from the repo root, replacing `<package>` with the folder name in `config/` you turned off (e.g. `karabiner` for `STOW_KARABINER`): `stow -D -d config -t ~ <package>`.
