# Dotfiles

Welcome to my dotfiles repository. The scripts and configurations here describe a portable macOS development workspace and automate installing tooling, symlinks, and shell helpers for a new machine.

## Overview

This repo uses a single installer to bootstrap Homebrew, deploy Brewfiles, stow configuration packages into `~/.config`, and add shared zsh aliases. It optionally runs a second, private installer that layers sensitive or personal tweaks on top of the public dotfiles.

## Setup

1. **Clone the repository:**

   ```sh
   git clone git@github.com:hvalec427/dotfiles.git
   cd dotfiles
   ```

   or this if also including private repo(this is for me only)

   ```sh
   git clone --recurse-submodules git@github.com:hvalec427/dotfiles.git
   cd dotfiles
   ```

   or if I forget
   ```sh
   git submodule update --init --recursive
   ```

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

The `private/` directory contains additional dotfiles, tmux helpers, and Brewfiles that are not tracked in the public repository.
