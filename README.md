# Termstack

Termstack bootstraps a customized Linux command-line environment. It installs a curated set of tools, provides Zsh and Fish configurations, and sets up the [Starship](https://starship.rs) prompt.

## Features

- 🛠 Automated package installation and symlink replacement for modern CLI tools
- ⚡ Zsh or Fish shell configuration with plugin managers (`zinit` and `fisher`)
- 🎨 Optional Starship prompt with shared configuration
- 🔧 Tmux config, handy aliases, and smart defaults
- 📚 Documentation and cheat sheets for quick reference

## Installation

Clone the repo and run the installer:

```bash
git clone https://github.com/azcoigreach/termstack.git
cd termstack
./install.sh
```

During installation you'll be prompted to choose which shell to install and whether to enable the Starship prompt.

## Documentation

- [`docs/command_reference.md`](docs/command_reference.md) – list of installed tools and links
- [`docs/cheatsheet.md`](docs/cheatsheet.md) – common commands and tips

Configuration files are located under `config/`. Symlinks to replace classic tools are installed to `$HOME/bin`; ensure it's on your `$PATH`.
