# Fish configuration with Starship prompt
# Source this file in your ~/.config/fish/config.fish

# Initialize Starship prompt with error handling
if type -q starship
    starship init fish | source
else
    echo "Warning: Starship not found. Please install it from https://starship.rs/install"
end

# Fish-specific settings
set -g fish_greeting ""
set -g fish_autosuggestion_enabled 1
set -g fish_autosuggestion_highlight_comment 0x6c757d
set -g fish_autosuggestion_highlight_strategy history

# Color scheme
set -g fish_color_normal normal
set -g fish_color_command 00ff00
set -g fish_color_quote 00ffff
set -g fish_color_redirection ffff00
set -g fish_color_end 00ff00
set -g fish_color_error ff0000
set -g fish_color_param 00ffff
set -g fish_color_comment 6c757d
set -g fish_color_match --background=brblue
set -g fish_color_selection white --bold --background=brblack
set -g fish_color_search_match bryellow --background=brblack
set -g fish_color_history_current --bold
set -g fish_color_host normal
set -g fish_color_host_remote yellow
set -g fish_color_status red

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Function to create and navigate to directories
function mkcd
    mkdir -p $argv[1] && cd $argv[1]
end

# Function to extract various archive formats
function extract
    if test -f $argv[1]
        switch $argv[1]
            case "*.tar.bz2"
                tar xjf $argv[1]
            case "*.tar.gz"
                tar xzf $argv[1]
            case "*.bz2"
                bunzip2 $argv[1]
            case "*.rar"
                unrar e $argv[1]
            case "*.gz"
                gunzip $argv[1]
            case "*.tar"
                tar xf $argv[1]
            case "*.tbz2"
                tar xjf $argv[1]
            case "*.tgz"
                tar xzf $argv[1]
            case "*.zip"
                unzip $argv[1]
            case "*.Z"
                uncompress $argv[1]
            case "*.7z"
                7z x $argv[1]
            case "*"
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Set PATH
set -gx PATH $HOME/.local/bin $PATH

# Set default editor
set -gx EDITOR nano
set -gx VISUAL nano

# Fish-specific functions
function fish_user_key_bindings
    fish_vi_key_bindings
end

# Enhanced ls colors
if command -v dircolors > /dev/null
    eval (dircolors -c | sed 's/>&\/dev\/null$//')
end

# Abbreviations for common commands
abbr -a -- - 'cd -'
abbr -a -- .. 'cd ..'
abbr -a -- ... 'cd ../..'
abbr -a -- .... 'cd ../../..'
abbr -a -- ll 'ls -la'
abbr -a -- la 'ls -A'
abbr -a -- l 'ls -CF'
abbr -a -- gs 'git status'
abbr -a -- ga 'git add'
abbr -a -- gc 'git commit'
abbr -a -- gp 'git push'
abbr -a -- gl 'git log --oneline'
abbr -a -- gd 'git diff'
