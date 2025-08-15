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

# Test function
test_command() {
    local cmd="$1"
    local description="$2"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        log_success "$description: $cmd found at $(which $cmd)"
        return 0
    else
        log_error "$description: $cmd not found"
        return 1
    fi
}

# Test symlink function
test_symlink() {
    local symlink="$1"
    local target="$2"
    local description="$3"
    
    if [ -L "$symlink" ] && [ -e "$symlink" ]; then
        local actual_target=$(readlink "$symlink")
        if [ "$actual_target" = "$target" ]; then
            log_success "$description: $symlink -> $target"
            return 0
        else
            log_warning "$description: $symlink -> $actual_target (expected $target)"
            return 1
        fi
    else
        log_error "$description: $symlink not found or not a symlink"
        return 1
    fi
}

# Main test function
main() {
    log_info "Testing termstack installation..."
    echo ""
    
    # Test system packages
    log_info "Testing system packages..."
    test_command "btop" "System monitor"
    test_command "tmux" "Terminal multiplexer"
    test_command "fzf" "Fuzzy finder"
    test_command "zoxide" "Smart cd replacement"
    test_command "unzip" "Archive extractor"
    test_command "curl" "HTTP client"
    test_command "git" "Version control"
    echo ""
    
    # Test enhanced tools
    log_info "Testing enhanced tools..."
    test_command "exa" "Enhanced ls (exa)"
    test_command "bat" "Enhanced cat (bat)"
    test_command "rg" "Enhanced grep (ripgrep)"
    test_command "fd" "Enhanced find (fd-find)"
    test_command "starship" "Starship prompt"
    echo ""
    
    # Test symlinks
    log_info "Testing symlinks..."
    test_symlink "$HOME/bin/ls" "/usr/local/bin/exa" "ls symlink"
    test_symlink "$HOME/bin/cat" "/usr/local/bin/bat" "cat symlink"
    test_symlink "$HOME/bin/grep" "/usr/local/bin/rg" "grep symlink"
    test_symlink "$HOME/bin/find" "/usr/local/bin/fd" "find symlink"
    test_symlink "$HOME/bin/fd" "/usr/local/bin/fd" "fd symlink"
    echo ""
    
    # Test shell configuration
    log_info "Testing shell configuration..."
    test_command "fish" "Fish shell"
    test_command "zsh" "Zsh shell"
    
    # Check default shell
    local default_shell=$(cat /etc/passwd | grep "^$USER:" | cut -d: -f7)
    if [ "$default_shell" = "/usr/bin/fish" ]; then
        log_success "Fish shell is set as default: $default_shell"
    else
        log_warning "Fish shell is not default. Current: $default_shell"
    fi
    echo ""
    
    # Test PATH configuration
    log_info "Testing PATH configuration..."
    if [[ ":$PATH:" == *":$HOME/bin:"* ]]; then
        log_success "PATH includes $HOME/bin"
    else
        log_warning "PATH does not include $HOME/bin"
        log_info "Current PATH: $PATH"
    fi
    echo ""
    
    # Test font installation
    log_info "Testing font installation..."
    if [ -d "$HOME/.local/share/fonts" ] && [ "$(ls -A "$HOME/.local/share/fonts")" ]; then
        log_success "Fonts found in $HOME/.local/share/fonts"
        ls "$HOME/.local/share/fonts" | grep -i roboto | head -3
    else
        log_warning "No fonts found in $HOME/.local/share/fonts"
    fi
    echo ""
    
    # Test actual command functionality
    log_info "Testing command functionality..."
    
    # Test enhanced ls
    if command -v exa >/dev/null 2>&1; then
        log_info "Testing enhanced ls (exa)..."
        if ls --version >/dev/null 2>&1; then
            log_success "Enhanced ls working"
        else
            log_error "Enhanced ls not working"
        fi
    fi
    
    # Test enhanced cat
    if command -v bat >/dev/null 2>&1; then
        log_info "Testing enhanced cat (bat)..."
        if cat --version >/dev/null 2>&1; then
            log_success "Enhanced cat working"
        else
            log_error "Enhanced cat not working"
        fi
    fi
    
    # Test enhanced grep
    if command -v rg >/dev/null 2>&1; then
        log_info "Testing enhanced grep (ripgrep)..."
        if grep --version >/dev/null 2>&1; then
            log_success "Enhanced grep working"
        else
            log_error "Enhanced grep not working"
        fi
    fi
    
    # Test enhanced find
    if command -v fd >/dev/null 2>&1; then
        log_info "Testing enhanced find (fd-find)..."
        if find --version >/dev/null 2>&1; then
            log_success "Enhanced find working"
        else
            log_error "Enhanced find not working"
        fi
    fi
    echo ""
    
    # Test fish shell
    log_info "Testing fish shell..."
    if fish -c "echo 'Fish shell test successful'" >/dev/null 2>&1; then
        log_success "Fish shell working"
    else
        log_error "Fish shell not working"
    fi
    echo ""
    
    log_info "Installation test completed!"
    log_info "To start using fish shell, log out and log back in, or run: fish"
    log_info "To use enhanced commands, ensure PATH includes $HOME/bin"
}

# Run main function
main "$@"

