#!/bin/bash

# Test script for Starship configuration
# This script tests if Starship is properly configured

set -e

echo "🧪 Testing Starship configuration..."

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

# Test 1: Check if Starship is installed
print_status "Testing Starship installation..."
if command -v starship &> /dev/null; then
    VERSION=$(starship --version)
    print_success "Starship is installed: $VERSION"
else
    print_error "Starship is not installed!"
    exit 1
fi

# Test 2: Check if configuration file exists
print_status "Testing configuration file..."
if [ -f ~/.config/starship.toml ]; then
    print_success "Configuration file exists at ~/.config/starship.toml"
else
    print_error "Configuration file not found!"
    exit 1
fi

# Test 3: Validate configuration
print_status "Validating configuration..."
if starship print-config &>/dev/null; then
    print_success "Configuration is valid!"
else
    print_error "Configuration has errors!"
    exit 1
fi

# Test 4: Check configuration content
print_status "Checking configuration content..."
if grep -q "format = " ~/.config/starship.toml; then
    print_success "Configuration contains format definition"
else
    print_warning "Configuration may be incomplete"
fi

# Test 5: Test prompt generation
print_status "Testing prompt generation..."
PROMPT=$(starship prompt)
if [ -n "$PROMPT" ]; then
    print_success "Prompt generation works: $PROMPT"
else
    print_warning "Prompt generation returned empty string"
fi

# Test 6: Check for specific modules
print_status "Checking for key modules..."
MODULES=("git_branch" "python" "nodejs" "directory" "username")
for module in "${MODULES[@]}"; do
    if grep -q "\[$module\]" ~/.config/starship.toml; then
        print_success "Module $module found"
    else
        print_warning "Module $module not found"
    fi
done

# Test 7: Check shell integration
print_status "Testing shell integration..."
if [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="unknown"
fi

print_status "Current shell: $SHELL_TYPE"

# Test 8: Check if Starship is initialized in current shell
if [ "$SHELL_TYPE" = "bash" ] || [ "$SHELL_TYPE" = "zsh" ]; then
    if [ -n "$STARSHIP_CONFIG" ]; then
        print_success "STARSHIP_CONFIG is set: $STARSHIP_CONFIG"
    else
        print_warning "STARSHIP_CONFIG is not set"
    fi
fi

echo ""
print_success "All tests completed! 🎉"
echo ""
echo "If you want to test the prompt in your current shell:"
echo "  eval \"\$(starship init $SHELL_TYPE)\""
echo ""
echo "To make the configuration permanent, run:"
echo "  ./setup_starship.sh"
