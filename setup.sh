#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect shell
detect_shell() {
    if [ -n "${SHELL:-}" ]; then
        basename "$SHELL"
    else
        echo "bash"
    fi
}

# Add PATH to shell config
add_path_to_shell() {
    local shell_type="$1"
    local config_file=""
    
    case "$shell_type" in
        bash)
            config_file="$HOME/.bashrc"
            ;;
        zsh)
            config_file="$HOME/.zshrc"
            ;;
        fish)
            config_file="$HOME/.config/fish/config.fish"
            ;;
        *)
            log_warning "Unknown shell type: $shell_type"
            return 1
            ;;
    esac
    
    if [ ! -f "$config_file" ]; then
        log_info "Creating $config_file..."
        touch "$config_file"
    fi
    
    # Check if PATH is already added
    if ! grep -q "export PATH=\"\$HOME/bin:\$PATH\"" "$config_file"; then
        echo "" >> "$config_file"
        echo "# Added by termstack installation" >> "$config_file"
        echo 'export PATH="$HOME/bin:$PATH"' >> "$config_file"
        log_success "Added PATH to $config_file"
    else
        log_info "PATH already configured in $config_file"
    fi
}

# Create starship config
create_starship_config() {
    local config_dir="$HOME/.config"
    local config_file="$config_dir/starship.toml"
    
    mkdir -p "$config_dir"
    
    if [ ! -f "$config_file" ]; then
        log_info "Creating starship configuration..."
        cat > "$config_file" << 'EOF'
# Starship configuration
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$rust\
$golang\
$docker_context\
$aws\
$kubernetes\
$terraform\
$helm\
$cmd_duration\
$line_break\
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[directory]
truncation_length = 3
truncation_symbol = "…/"
style = "blue bold"

[git_branch]
symbol = " "
style = "purple bold"

[git_status]
style = "red bold"
ahead = "⇡\${count}"
behind = "⇣\${count}"
diverged = "⇕⇡\${ahead_count}⇣\${behind_count}"
untracked = "?"
stashed = "≡"
modified = "!"
staged = "+"
renamed = "»"
deleted = "✘"

[cmd_duration]
min_time = 2000
style = "yellow"

[nodejs]
symbol = " "
style = "green bold"

[python]
symbol = " "
style = "yellow bold"

[rust]
symbol = " "
style = "red bold"

[golang]
symbol = " "
style = "cyan bold"

[docker_context]
symbol = " "
style = "blue bold"

[aws]
symbol = " "
style = "yellow bold"

[kubernetes]
symbol = " "
style = "blue bold"

[terraform]
symbol = " "
style = "purple bold"

[helm]
symbol = " "
style = "blue bold"
EOF
        log_success "Created starship configuration at $config_file"
    else
        log_info "Starship configuration already exists at $config_file"
    fi
}

# Show font setup instructions
show_font_instructions() {
    log_info "Font Setup Instructions:"
    echo ""
    echo "RobotoMono Nerd Font has been installed. To use it:"
    echo ""
    echo "1. Restart your terminal application"
    echo "2. Go to your terminal preferences/settings"
    echo "3. Change the font to one of these options:"
    echo "   - RobotoMono Nerd Font"
    echo "   - RobotoMono Nerd Font Mono"
    echo "   - RobotoMono Nerd Font Propo"
    echo ""
    echo "4. Recommended font size: 12-14pt"
    echo ""
    echo "The font includes various weights (Thin, Light, Regular, Medium, SemiBold, Bold)"
    echo "and styles (Regular, Italic) - choose what looks best in your terminal."
    echo ""
}

# Main function
main() {
    log_info "Running post-installation setup..."
    
    # Detect shell
    local shell_type=$(detect_shell)
    log_info "Detected shell: $shell_type"
    
    # Add PATH to shell config
    add_path_to_shell "$shell_type"
    
    # Create starship config
    create_starship_config
    
    # Show font instructions
    show_font_instructions
    
    log_success "Setup completed!"
    log_info "To apply changes:"
    echo "1. Restart your terminal or run: source ~/.${shell_type}rc"
    echo "2. Change your terminal font to RobotoMono Nerd Font"
    echo "3. Test the new commands: ls, cat, grep, find"
}

# Run main function
main "$@"
