# Dotfiles

Welcome to my dotfiles repository. The scripts and configurations here describe a portable macOS development workspace and automate installing tooling, symlinks, and shell helpers for a new machine.

## Overview

This repo uses a single installer to bootstrap Homebrew, deploy Brewfiles, stow configuration packages into `~/.config`, and add shared zsh aliases. It optionally runs a second, private installer that layers sensitive or personal tweaks on top of the public dotfiles.

## Quick start (new machine)

One line, no prerequisites beyond `git` and `curl`:

```sh
curl -fsSL https://raw.githubusercontent.com/hvalec427/dotfiles/master/bootstrap.sh | bash
```

This clones the repo to `~/dev/dotfiles` over HTTPS (works with no SSH key) and runs `install.sh`. If the private repo is reachable over SSH it switches `origin` to SSH so pushes work; otherwise it keeps HTTPS so re-running the command later keeps working without a key. The private submodule is pulled during install and needs a GitHub SSH key (see [Private configuration](#private-configuration)).

## Manual setup

1. **Clone the repository:**

   ```sh
   git clone git@github.com:hvalec427/dotfiles.git
   cd dotfiles
   ```

   The installer pulls in the private submodule on its own (see [Private configuration](#private-configuration)), so a plain clone is enough.

2. **Make the installer executable:**

   ```sh
   chmod +x install.sh
   ```

3. **Run the installer:**

   ```sh
   ./install.sh
   ```

4. **Re-running the installer** is safe; it will only reapply missing symlinks or clone missing repos.

## Private configuration

The `private/` directory contains additional dotfiles, tmux helpers, and Brewfiles that are not tracked in the public repository. It's a git submodule pointing at a private repo.

`install.sh` initializes and clones this submodule automatically, then runs its installer, so there's no manual clone step. This requires a GitHub SSH key with access to the private repo — without it, the installer prints `No credentials. Skipping...` and continues with just the public config.
