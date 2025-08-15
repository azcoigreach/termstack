#!/usr/bin/env bash
set -e

PACKAGES="btop tmux exa bat ripgrep fd-find fzf zoxide entr mc starship"

install_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y "$PACKAGES" zsh fish curl git
  else
    echo "Package manager not supported. Install packages manually: $PACKAGES" >&2
  fi
}

create_symlinks() {
  mkdir -p "$HOME/bin"
  ln -sf "$(command -v exa)" "$HOME/bin/ls"
  ln -sf "$(command -v batcat 2>/dev/null || command -v bat)" "$HOME/bin/cat"
  ln -sf "$(command -v rg)" "$HOME/bin/grep"
  ln -sf "$(command -v fdfind 2>/dev/null || command -v fd)" "$HOME/bin/find"
  ln -sf "$(command -v fdfind 2>/dev/null || command -v fd)" "$HOME/bin/fd"
}

install_zsh() {
  sudo apt-get install -y zsh
  if [ ! -f "${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh" ]; then
    mkdir -p "${ZDOTDIR:-$HOME}/.zinit"
    git clone https://github.com/zdharma-continuum/zinit.git "${ZDOTDIR:-$HOME}/.zinit/bin"
  fi
}

install_fish() {
  sudo apt-get install -y fish
  if ! command -v fisher >/dev/null 2>&1; then
    curl -sL https://git.io/fisher | fish && fisher install jorgebucaran/fisher
  fi
}

install_starship() {
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
}

main() {
  install_packages
  create_symlinks

  read -rp "Install a shell? (default/zsh/fish) [default]: " shell_choice
  case "$shell_choice" in
    zsh|ZSH)
      install_zsh
      ;;
    fish|FISH)
      install_fish
      ;;
    *)
      echo "Leaving default shell."
      ;;
  esac

  read -rp "Install starship prompt? (y/N): " starship_choice
  if [[ "$starship_choice" =~ ^[Yy]$ ]]; then
    install_starship
  fi

  echo "Installation complete. Add $HOME/bin to your PATH for the aliases."
}

main "$@"
