#!/bin/bash

# Starship Setup Script
# This script installs Starship and configures it for bash, fish, and zsh

set -e

echo "🚀 Setting up Starship prompt for bash, fish, and zsh..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Starship is already installed
if command -v starship &> /dev/null; then
    print_status "Starship is already installed: $(starship --version)"
else
    print_status "Installing Starship..."
    
    # Install Starship using the official install script
    if curl -sS https://starship.rs/install.sh | sh; then
        print_success "Starship installed successfully!"
    else
        print_error "Failed to install Starship. Please install manually from https://starship.rs/install"
        exit 1
    fi
fi

# Create backup of existing shell configs
print_status "Creating backups of existing shell configurations..."

# Backup bashrc
if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
    print_status "Backed up ~/.bashrc"
fi

# Backup fish config
if [ -f ~/.config/fish/config.fish ]; then
    mkdir -p ~/.config/fish/backup
    cp ~/.config/fish/config.fish ~/.config/fish/backup/config.fish.backup.$(date +%Y%m%d_%H%M%S)
    print_status "Backed up ~/.config/fish/config.fish"
fi

# Backup zshrc
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    print_status "Backed up ~/.zshrc"
fi

# Copy Starship configuration
print_status "Installing Starship configuration..."
if [ -f config/starship.toml ]; then
    mkdir -p ~/.config
    cp config/starship.toml ~/.config/starship.toml
    print_success "Starship configuration installed to ~/.config/starship.toml"
else
    print_error "Starship configuration file not found!"
    exit 1
fi

# Configure bash
print_status "Configuring bash..."
if [ -f config/bashrc ]; then
    # Check if already sourced
    if ! grep -q "starship init bash" ~/.bashrc; then
        echo "" >> ~/.bashrc
        echo "# Starship prompt configuration" >> ~/.bashrc
        echo "source $(pwd)/config/bashrc" >> ~/.bashrc
        print_success "Bash configured! Source ~/.bashrc or restart your terminal."
    else
        print_warning "Bash already configured for Starship."
    fi
else
    print_error "Bash configuration file not found!"
fi

# Configure fish
print_status "Configuring fish..."
if [ -f config/config.fish ]; then
    mkdir -p ~/.config/fish
    if [ -f ~/.config/fish/config.fish ]; then
        # Check if already sourced
        if ! grep -q "starship init fish" ~/.config/fish/config.fish; then
            echo "" >> ~/.config/fish/config.fish
            echo "# Starship prompt configuration" >> ~/.config/fish/config.fish
            echo "source $(pwd)/config/config.fish" >> ~/.config/fish/config.fish
            print_success "Fish configured! Source ~/.config/fish/config.fish or restart your terminal."
        else
            print_warning "Fish already configured for Starship."
        fi
    else
        cp config/config.fish ~/.config/fish/config.fish
        print_success "Fish configured! Restart your terminal or run 'source ~/.config/fish/config.fish'"
    fi
else
    print_error "Fish configuration file not found!"
fi

# Configure zsh
print_status "Configuring zsh..."
if [ -f config/zshrc ]; then
    if [ -f ~/.zshrc ]; then
        # Check if already sourced
        if ! grep -q "starship init zsh" ~/.zshrc; then
            echo "" >> ~/.zshrc
            echo "# Starship prompt configuration" >> ~/.zshrc
            echo "source $(pwd)/config/zshrc" >> ~/.zshrc
            print_success "Zsh configured! Source ~/.zshrc or restart your terminal."
        else
            print_warning "Zsh already configured for Starship."
        fi
    else
        cp config/zshrc ~/.zshrc
        print_success "Zsh configured! Restart your terminal or run 'source ~/.zshrc'"
    fi
else
    print_error "Zsh configuration file not found!"
fi

# Check for nerd fonts
print_status "Checking for Nerd Fonts..."
if fc-list | grep -q "Nerd Font\|NerdFont" 2>/dev/null; then
    print_success "Nerd Fonts detected! Your prompt will look great."
else
    print_warning "Nerd Fonts not detected. Consider installing a Nerd Font for the best experience:"
    echo "   https://www.nerdfonts.com/font-downloads"
fi

# Test Starship configuration
print_status "Testing Starship configuration..."
if starship print-config &>/dev/null; then
    print_success "Starship configuration is valid!"
else
    print_error "Starship configuration has errors. Please check ~/.config/starship.toml"
fi

echo ""
print_success "Setup complete! 🎉"
echo ""
echo "To activate the new prompt:"
echo "  Bash:  source ~/.bashrc  or restart terminal"
echo "  Fish:  source ~/.config/fish/config.fish  or restart terminal"
echo "  Zsh:   source ~/.zshrc  or restart terminal"
echo ""
echo "Or simply restart your terminal for all changes to take effect."
echo ""
echo "Your prompt will now show:"
echo "  • Username and hostname"
echo "  • Current directory with git status"
echo "  • Programming language versions (Python, Node.js, Rust, Go)"
echo "  • Docker and Kubernetes context"
echo "  • AWS profile and region"
echo "  • Memory usage and battery status"
echo "  • Current time"
echo "  • Command duration for long-running commands"
echo ""
echo "Enjoy your new informative and beautiful prompt! ✨"
