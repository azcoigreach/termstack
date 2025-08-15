if status is-interactive
    # Initialize tools
    if type -q zoxide
        zoxide init fish | source
    end
    if type -q starship
        starship init fish | source
    end

    # Aliases
    alias ls "exa --icons"
    alias cat "bat"
    alias grep "rg"
    alias find "fd"
end
