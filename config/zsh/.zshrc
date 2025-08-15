# Load zinit if available, otherwise install it
if [ ! -f ${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh ]; then
  mkdir -p ${ZDOTDIR:-$HOME}/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ${ZDOTDIR:-$HOME}/.zinit/bin
fi
source ${ZDOTDIR:-$HOME}/.zinit/bin/zinit.zsh

# Plugins
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# Aliases
alias ls='exa --icons'
alias cat='bat'
alias grep='rg'
alias find='fd'

# Tools
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
