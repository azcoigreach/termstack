# Fish shell configuration for termstack

# Add ~/bin to PATH for enhanced commands
set -gx PATH "$HOME/bin" $PATH

# Initialize starship prompt
starship init fish | source

# Fish-specific settings
set -g fish_greeting ""

# Enhanced ls colors (if using exa)
if command -q exa
    alias ls='exa --icons --color=always'
    alias ll='exa --icons --color=always -l'
    alias la='exa --icons --color=always -la'
end

# Enhanced cat (bat)
if command -q bat
    alias cat='bat'
end

# Enhanced grep (ripgrep)
if command -q rg
    alias grep='rg'
end

# Enhanced find (fd)
if command -q fd
    alias find='fd'
end

# Zoxide (smart cd)
if command -q zoxide
    zoxide init fish | source
end

# FZF integration
if command -q fzf
    set -g FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'
end

