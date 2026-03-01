# Dotfiles

Welcome to my dotfiles repository! This collection contains configuration files and scripts to help set up and personalize my development environment quickly and efficiently.

## Overview

These dotfiles are designed to automate the setup of essential tools, applications, and preferences on a new system. Whether configuring a fresh machine or keeping my environment consistent across devices, this repository makes the process seamless.

## Usage

1. **Clone the repository:**
	```sh
	git clone https://github.com/hvalec/dotfiles.git
	cd dotfiles
	```


2. **Make the install script executable (if needed):**
	```sh
	chmod +x bootstrap/install.sh
	```

3. **Run the bootstrap script:**
	```sh
	./bootstrap/install.sh
	```

4. **Follow on-screen instructions to complete the setup.**

## Notes

- The setup script will install essential packages and apply configuration files automatically.
- It allows me some customization depending on current machines needs.

### What Gets Installed Automatically?

When running the install.sh script, the following actions are performed:

- **homebrew** is installed if not already present.
- **gum** (for interactive prompts) is installed if missing.
- **stow** is installed if needed, and used to manage symlinks for selected configs.

This process ensures system is set up with needed tools and configurations automatically, streamlining environment setup.