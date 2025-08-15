#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
INSTALL_SHELL="default"
INSTALL_STARSHIP="N"
INSTALL_FONT="N"
NON_INTERACTIVE=false

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --shell)
                INSTALL_SHELL="$2"
                shift 2
                ;;
            --starship)
                INSTALL_STARSHIP="$2"
                shift 2
                ;;
            --font)
                INSTALL_FONT="$2"
                shift 2
                ;;
            --non-interactive|-y)
                NON_INTERACTIVE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    --shell SHELL          Shell to install (default/zsh/fish) [default: default]
    --starship Y/N         Install starship prompt (Y/N) [default: N]
    --font Y/N             Install RobotoMono Nerd Font (Y/N) [default: N]
    --non-interactive, -y  Run without user interaction
    --help, -h             Show this help message

Examples:
    $0 --non-interactive --shell fish --starship Y --font Y
    $0 --shell zsh --starship Y
    $0 -y
EOF
}

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

# Package lists - split into available and unavailable
AVAILABLE_PACKAGES="btop tmux fzf zoxide entr mc curl git unzip zsh"
UNAVAILABLE_PACKAGES="exa bat ripgrep fd-find starship"

# Detect package manager
detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    else
        echo "unknown"
    fi
}

# Check if a package is available
package_available() {
    local pkg="$1"
    local pkg_manager=$(detect_package_manager)
    
    case "$pkg_manager" in
        apt)
            # Use a more lenient check for apt
            apt-cache search --names-only "$pkg" | grep -q "$pkg"
            ;;
        dnf|yum)
            yum list available "$pkg" >/dev/null 2>&1
            ;;
        pacman)
            pacman -Ss "^$pkg$" >/dev/null 2>&1
            ;;
        zypper)
            zypper search "$pkg" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# Install packages based on detected package manager
install_packages() {
    local pkg_manager=$(detect_package_manager)
    local packages_to_install=""
    
    log_info "Detected package manager: $pkg_manager"
    
    # Check which packages are available
    for pkg in $AVAILABLE_PACKAGES; do
        if package_available "$pkg"; then
            packages_to_install="$packages_to_install $pkg"
            log_info "Package $pkg available in repositories"
        else
            log_warning "Package $pkg not available in repositories"
        fi
    done
    
    if [ -z "$packages_to_install" ]; then
        log_warning "No packages available to install from repositories"
        return 0
    fi
    
    case "$pkg_manager" in
        apt)
            log_info "Updating package list..."
            sudo apt-get update
            log_info "Installing available packages: $packages_to_install"
            sudo apt-get install -y $packages_to_install
            ;;
        dnf)
            log_info "Installing packages: $packages_to_install"
            sudo dnf install -y $packages_to_install
            ;;
        yum)
            log_info "Installing packages: $packages_to_install"
            sudo yum install -y $packages_to_install
            ;;
        pacman)
            log_info "Installing packages: $packages_to_install"
            sudo pacman -S --noconfirm $packages_to_install
            ;;
        zypper)
            log_info "Installing packages: $packages_to_install"
            sudo zypper install -y $packages_to_install
            ;;
        *)
            log_error "Unsupported package manager: $pkg_manager"
            log_warning "Please install the following packages manually: $packages_to_install"
            return 1
            ;;
    esac
    
    log_success "Package installation completed"
}

# Install fish shell if requested
install_fish_shell() {
    local pkg_manager=$(detect_package_manager)
    
    log_info "Installing Fish shell..."
    
    case "$pkg_manager" in
        apt)
            sudo apt-get install -y fish
            ;;
        dnf)
            sudo dnf install -y fish
            ;;
        yum)
            sudo yum install -y fish
            ;;
        pacman)
            sudo pacman -S --noconfirm fish
            ;;
        zypper)
            sudo zypper install -y fish
            ;;
        *)
            log_error "Cannot install fish with package manager: $pkg_manager"
            return 1
            ;;
    esac
    
    if command -v fish >/dev/null 2>&1; then
        log_success "Fish shell installed successfully"
        return 0
    else
        log_error "Failed to install fish shell"
        return 1
    fi
}

# Install unavailable packages from alternative sources
install_unavailable_packages() {
    log_info "Installing packages not available in repositories..."
    
    # Install ripgrep (rg)
    if ! command -v rg >/dev/null 2>&1; then
        log_info "Installing ripgrep..."
        if curl -L https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz | tar -xz --strip-components=1 -C /tmp; then
            sudo cp /tmp/rg /usr/local/bin/
            log_success "ripgrep installed"
        else
            log_warning "Failed to install ripgrep"
        fi
    fi
    
    # Install fd-find
    if ! command -v fd >/dev/null 2>&1; then
        log_info "Installing fd-find..."
        if curl -L https://github.com/sharkdp/fd/releases/download/v8.7.0/fd-v8.7.0-x86_64-unknown-linux-gnu.tar.gz | tar -xz --strip-components=1 -C /tmp; then
            sudo cp /tmp/fd /usr/local/bin/
            log_success "fd-find installed"
        else
            log_warning "Failed to install fd-find"
        fi
    fi
    
    # Install bat
    if ! command -v bat >/dev/null 2>&1; then
        log_info "Installing bat..."
        if curl -L https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-gnu.tar.gz | tar -xz --strip-components=1 -C /tmp; then
            sudo cp /tmp/bat /usr/local/bin/
            log_success "bat installed"
        else
            log_warning "Failed to install bat"
        fi
    fi
    
    # Install exa (or use eza if available)
    if ! command -v exa >/dev/null 2>&1; then
        log_info "Installing exa..."
        if curl -L https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip -o /tmp/exa.zip && cd /tmp && unzip -o exa.zip && sudo cp bin/exa /usr/local/bin/; then
            log_success "exa installed"
        else
            log_warning "Failed to install exa"
        fi
    fi
    
    # Install starship
    if ! command -v starship >/dev/null 2>&1; then
        log_info "Installing starship..."
        if curl -sS https://starship.rs/install.sh | sh -s -- --yes; then
            log_success "starship installed"
        else
            log_warning "Failed to install starship"
        fi
    fi
    
    # Install entr (file change monitor)
    if ! command -v entr >/dev/null 2>&1; then
        log_info "Installing entr..."
        # Try multiple sources for entr
        local entr_installed=false
        
        # Try from entr official site with proper Makefile detection
        if curl -L http://eradman.com/entrproject/code/entr-5.4.tar.gz | tar -xz -C /tmp && cd /tmp && find . -name "entr-*" -type d | head -1 | xargs -I {} sh -c 'cd {} && ls -la && if [ -f Makefile.linux ]; then make -f Makefile.linux; elif [ -f Makefile ]; then make; else echo "No suitable Makefile found"; exit 1; fi && sudo cp entr /usr/local/bin/'; then
            log_success "entr installed from source"
            entr_installed=true
        else
            log_warning "Failed to install entr from source"
        fi
        
        # Try from GitHub releases (different version)
        if [ "$entr_installed" = false ]; then
            if curl -L https://github.com/eradman/entr/releases/download/5.3/entr-5.3-linux-x86_64.tar.gz | tar -xz -C /tmp && sudo cp /tmp/entr /usr/local/bin/; then
                log_success "entr installed from GitHub"
                entr_installed=true
            else
                log_warning "Failed to install entr from GitHub"
            fi
        fi
        
        # Try building from source with proper directory structure and Makefile selection
        if [ "$entr_installed" = false ]; then
            log_info "Trying to build entr from source with proper structure..."
            if curl -L http://eradman.com/entrproject/code/entr-5.4.tar.gz | tar -xz -C /tmp && cd /tmp && find . -name "entr-*" -type d | head -1 | xargs -I {} sh -c 'cd {} && ls -la && if [ -f Makefile.linux ]; then make -f Makefile.linux; elif [ -f Makefile ]; then make; else echo "No suitable Makefile found"; exit 1; fi && sudo cp entr /usr/local/bin/'; then
                log_success "entr installed from source (auto-detected directory)"
                entr_installed=true
            else
                log_warning "Failed to install entr from source (auto-detected directory)"
            fi
        fi
        
        if [ "$entr_installed" = false ]; then
            log_warning "Could not install entr from any source"
        fi
    fi
    
    # Install mc (Midnight Commander) - try to use package manager first
    if ! command -v mc >/dev/null 2>&1; then
        log_info "Installing mc..."
        local mc_installed=false
        
        # Try to install from package manager with different names
        if command -v apt-get >/dev/null 2>&1; then
            if sudo apt-get install -y mc; then
                log_success "mc installed from package manager (apt)"
                mc_installed=true
            fi
        elif command -v dnf >/dev/null 2>&1; then
            if sudo dnf install -y mc; then
                log_success "mc installed from package manager"
                mc_installed=true
            fi
        elif command -v yum >/dev/null 2>&1; then
            if sudo yum install -y mc; then
                log_success "mc installed from package manager"
                mc_installed=true
            fi
        elif command -v pacman >/dev/null 2>&1; then
            if sudo pacman -S --noconfirm mc; then
                log_success "mc installed from package manager"
                mc_installed=true
            fi
        elif command -v zypper >/dev/null 2>&1; then
            if sudo zypper install -y mc; then
                log_success "mc installed from package manager"
                mc_installed=true
            fi
        fi
        
        # If package manager failed, try from source
        if [ "$mc_installed" = false ]; then
            log_info "Trying to install mc from source..."
            # Try multiple sources for mc with proper directory detection and autotools setup
            if curl -L https://github.com/MidnightCommander/mc/archive/refs/tags/4.8.31.tar.gz | tar -xz -C /tmp && cd /tmp && find . -name "mc-*" -type d | head -1 | xargs -I {} sh -c 'cd {} && ls -la && if [ -f autogen.sh ]; then ./autogen.sh && ./configure --prefix=/usr/local && make && sudo make install; elif [ -f configure ]; then ./configure --prefix=/usr/local && make && sudo make install; else echo "No configure script or autogen.sh found"; exit 1; fi'; then
                log_success "mc installed from source (GitHub)"
                mc_installed=true
            elif curl -L https://ftp.midnight-commander.org/mc-4.8.31.tar.gz | tar -xz -C /tmp && cd /tmp/mc-4.8.31 && ./configure --prefix=/usr/local && make && sudo make install; then
                log_success "mc installed from source (FTP)"
                mc_installed=true
            else
                log_warning "Failed to install mc from source"
            fi
        fi
        
        if [ "$mc_installed" = false ]; then
            log_warning "Could not install mc from any source"
        fi
    fi
}

# Verify that a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create symlinks with proper verification
create_symlinks() {
    log_info "Creating symlinks for enhanced commands..."
    
    # Ensure ~/bin directory exists (use actual user home, not root)
    local user_home=$(eval echo ~$SUDO_USER)
    if [ -z "$user_home" ] || [ "$user_home" = "~$SUDO_USER" ]; then
        user_home="$HOME"
    fi
    
    local bin_dir="$user_home/bin"
    mkdir -p "$bin_dir"
    log_info "Created/verified $bin_dir directory"
    
    # Function to create symlink with verification
    create_symlink() {
        local source_cmd="$1"
        local target_name="$2"
        local fallback_cmd="$3"
        
        local source_path=""
        if command_exists "$source_cmd"; then
            source_path=$(command -v "$source_cmd")
        elif [ -n "$fallback_cmd" ] && command_exists "$fallback_cmd"; then
            source_path=$(command -v "$fallback_cmd")
        else
            log_warning "Command $source_cmd not found, skipping symlink for $target_name"
            return 1
        fi
        
        local target_path="$bin_dir/$target_name"
        ln -sf "$source_path" "$target_path"
        
        if [ -L "$target_path" ] && [ -e "$target_path" ]; then
            log_success "Created symlink: $target_name -> $source_path"
        else
            log_error "Failed to create symlink for $target_name"
            return 1
        fi
    }
    
    # Create symlinks with fallbacks
    create_symlink "exa" "ls" ""
    create_symlink "bat" "cat" "batcat"
    create_symlink "rg" "grep" ""
    create_symlink "fd" "find" "fdfind"
    create_symlink "fd" "fd" "fdfind"
    
    log_success "Symlink creation completed"
}

# Install Zsh shell if requested
install_zsh_shell() {
    local pkg_manager=$(detect_package_manager)
    
    log_info "Installing Zsh shell..."
    
    case "$pkg_manager" in
        apt)
            sudo apt-get install -y zsh
            ;;
        dnf)
            sudo dnf install -y zsh
            ;;
        yum)
            sudo yum install -y zsh
            ;;
        pacman)
            sudo pacman -S --noconfirm zsh
            ;;
        zypper)
            sudo zypper install -y zsh
            ;;
        *)
            log_error "Cannot install zsh with package manager: $pkg_manager"
            return 1
            ;;
    esac
    
    if command -v zsh >/dev/null 2>&1; then
        log_success "Zsh shell installed successfully"
        return 0
    else
        log_error "Failed to install zsh shell"
        return 1
    fi
}

# Install Zsh with zinit
install_zsh() {
    log_info "Installing Zsh with zinit..."
    
    # Check if zsh is available, install if not
    if ! command_exists zsh; then
        log_info "Zsh not found, installing it first..."
        if ! install_zsh_shell; then
            log_error "Failed to install zsh shell"
            return 1
        fi
    fi
    
    # Get the correct user home directory for zinit installation
    local user_home=$(eval echo ~$SUDO_USER)
    if [ -z "$user_home" ] || [ "$user_home" = "~$SUDO_USER" ]; then
        user_home="$HOME"
    fi
    local zinit_dir="${ZDOTDIR:-$user_home}/.zinit"
    
    if [ ! -f "$zinit_dir/bin/zinit.zsh" ]; then
        log_info "Installing zinit..."
        mkdir -p "$zinit_dir"
        if git clone https://github.com/zdharma-continuum/zinit.git "$zinit_dir/bin"; then
            log_success "Zinit installed successfully"
        else
            log_error "Failed to install zinit"
            return 1
        fi
    else
        log_info "Zinit already installed"
    fi
    
    log_success "Zsh setup completed"
}

# Install Fish with fisher
install_fish() {
    log_info "Installing Fish with fisher..."
    
    # Check if fish is available
    if ! command_exists fish; then
        log_error "Fish is not installed. Please install it first."
        return 1
    fi
    
    # Install fisher if not present
    if ! command_exists fisher; then
        log_info "Installing fisher..."
        # Use the correct fisher installation method within fish shell
        if fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"; then
            log_success "Fisher installed successfully"
        else
            log_error "Failed to install fisher"
            return 1
        fi
    else
        log_info "Fisher already installed"
    fi
    
    # Always set fish as default shell when requested
    if [[ "$INSTALL_SHELL" =~ ^[Ff][Ii][Ss][Hh]$ ]]; then
        log_info "Setting fish as default shell..."
        if chsh -s "$(which fish)"; then
            log_success "Fish shell set as default. You'll need to log out and back in for changes to take effect."
            log_info "Current shell: $SHELL"
            log_info "New default shell: $(which fish)"
        else
            log_error "Failed to set fish as default shell"
            return 1
        fi
    fi
    
    log_success "Fish setup completed"
}

# Install RobotoMono Nerd Font
install_nerd_font() {
    log_info "Installing RobotoMono Nerd Font..."
    
    # Get the correct user home directory
    local user_home=$(eval echo ~$SUDO_USER)
    if [ -z "$user_home" ] || [ "$user_home" = "~$SUDO_USER" ]; then
        user_home="$HOME"
    fi
    
    local font_dir="$user_home/.local/share/fonts"
    local font_name="RobotoMono Nerd Font"
    
    # Create font directory if it doesn't exist
    mkdir -p "$font_dir"
    
    # Download and install the font
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/RobotoMono.zip"
    local temp_font_file="/tmp/RobotoMono.zip"
    
    log_info "Downloading RobotoMono Nerd Font..."
    if curl -L "$font_url" -o "$temp_font_file"; then
        log_info "Extracting font files..."
        if cd "$font_dir" && unzip -o "$temp_font_file" && rm "$temp_font_file"; then
            # Update font cache
            if command -v fc-cache >/dev/null 2>&1; then
                log_info "Updating font cache..."
                fc-cache -fv
            fi
            log_success "RobotoMono Nerd Font installed successfully"
            log_info "You may need to restart your terminal or change your font settings to use 'RobotoMono Nerd Font'"
            return 0
        else
            log_error "Failed to extract font files"
            rm -f "$temp_font_file"
            return 1
        fi
    else
        log_error "Failed to download RobotoMono Nerd Font"
        return 1
    fi
}

# Install Starship prompt
install_starship() {
    log_info "Installing Starship prompt..."
    
    if command_exists starship; then
        log_info "Starship already installed"
        return 0
    fi
    
    # Download and verify the installation script
    local temp_script=$(mktemp)
    if curl -fsSL https://starship.rs/install.sh -o "$temp_script"; then
        # Make it executable and run
        chmod +x "$temp_script"
        if "$temp_script" -y; then
            log_success "Starship installed successfully"
        else
            log_error "Failed to install Starship"
            rm -f "$temp_script"
            return 1
        fi
        rm -f "$temp_script"
    else
        log_error "Failed to download Starship installation script"
        return 1
    fi
}

# Validate user input
validate_choice() {
    local choice="$1"
    local valid_choices="$2"
    
    for valid in $valid_choices; do
        if [ "$choice" = "$valid" ]; then
            return 0
        fi
    done
    return 1
}

# Check if PATH includes ~/bin
check_path() {
    # Get the correct user home directory
    local user_home=$(eval echo ~$SUDO_USER)
    if [ -z "$user_home" ] || [ "$user_home" = "~$SUDO_USER" ]; then
        user_home="$HOME"
    fi
    local bin_dir="$user_home/bin"
    
    if [[ ":$PATH:" != *":$bin_dir:"* ]]; then
        log_warning "Add the following line to your shell configuration file (.bashrc, .zshrc, etc.):"
        echo "export PATH=\"$bin_dir:\$PATH\""
        log_info "Or run: export PATH=\"$bin_dir:\$PATH\" in your current shell"
    else
        log_success "PATH already includes $bin_dir"
    fi
}

# Verify installations
verify_installations() {
    log_info "Verifying installations..."
    
    # Get the correct user home directory
    local user_home=$(eval echo ~$SUDO_USER)
    if [ -z "$user_home" ] || [ "$user_home" = "~$SUDO_USER" ]; then
        user_home="$HOME"
    fi
    local bin_dir="$user_home/bin"
    
    # Check if packages are installed
    for pkg in $AVAILABLE_PACKAGES; do
        if ! command_exists "$pkg"; then
            log_warning "Package $pkg not found in repositories. It may be installed from alternative sources."
        else
            log_success "Package $pkg found."
        fi
    done
    
    # Check enhanced tools specifically
    local enhanced_tools="exa bat rg fd starship"
    for tool in $enhanced_tools; do
        if command_exists "$tool"; then
            log_success "Enhanced tool $tool found."
        else
            log_error "Enhanced tool $tool not found."
        fi
    done
    
    # Check if symlinks were created
    if [ -L "$bin_dir/ls" ] && [ -e "$bin_dir/ls" ]; then
        log_success "Symlink $bin_dir/ls -> exa created."
    else
        log_warning "Symlink $bin_dir/ls -> exa not found or is not a symlink."
    fi
    if [ -L "$bin_dir/cat" ] && [ -e "$bin_dir/cat" ]; then
        log_success "Symlink $bin_dir/cat -> bat created."
    else
        log_warning "Symlink $bin_dir/cat -> bat not found or is not a symlink."
    fi
    if [ -L "$bin_dir/grep" ] && [ -e "$bin_dir/grep" ]; then
        log_success "Symlink $bin_dir/grep -> rg created."
    else
        log_warning "Symlink $bin_dir/grep -> rg not found or is not a symlink."
    fi
    if [ -L "$bin_dir/find" ] && [ -e "$bin_dir/find" ]; then
        log_success "Symlink $bin_dir/find -> fd created."
    else
        log_warning "Symlink $bin_dir/find -> fd not found or is not a symlink."
    fi
    if [ -L "$bin_dir/fd" ] && [ -e "$bin_dir/fd" ]; then
        log_success "Symlink $bin_dir/fd -> fd created."
    else
        log_warning "Symlink $bin_dir/fd -> fd not found or is not a symlink."
    fi
    
    # Check if shells are available
    if command_exists zsh; then
        log_success "Zsh found."
    else
        log_warning "Zsh not found. It will be installed if requested."
    fi
    if command_exists fish; then
        log_success "Fish found."
    else
        log_error "Fish not found. Please install it."
    fi
    
    # Check if fonts are installed
    if [ -d "$user_home/.local/share/fonts" ] && [ "$(ls -A "$user_home/.local/share/fonts")" ]; then
        log_success "RobotoMono Nerd Font found in $user_home/.local/share/fonts."
    else
        log_warning "RobotoMono Nerd Font not found in $user_home/.local/share/fonts."
    fi
    
    # Check if starship is installed
    if command_exists starship; then
        log_success "Starship found."
    else
        log_error "Starship not found. Please install it."
    fi
    
    log_success "Installation verification completed."
}

# Main function
main() {
    log_info "Starting installation..."
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Check for sudo privileges
    if ! sudo -n true 2>/dev/null; then
        log_error "This script requires sudo privileges"
        exit 1
    fi
    
    log_info "Installation options:"
    log_info "  Shell: $INSTALL_SHELL"
    log_info "  Starship: $INSTALL_STARSHIP"
    log_info "  Font: $INSTALL_FONT"
    log_info "  Non-interactive: $NON_INTERACTIVE"
    
    # Install packages from repositories
    if ! install_packages; then
        log_error "Package installation failed"
        exit 1
    fi
    
    # Install unavailable packages from alternative sources
    install_unavailable_packages
    
    # Create symlinks
    if ! create_symlinks; then
        log_warning "Some symlinks could not be created"
    fi
    
    # Shell installation - interactive unless non-interactive mode or specific shell specified
    if [ "$NON_INTERACTIVE" = true ] || [ "$INSTALL_SHELL" != "default" ]; then
        # Use command line arguments
        case "$INSTALL_SHELL" in
            zsh|ZSH)
                if ! install_zsh; then
                    log_error "Zsh installation failed"
                fi
                ;;
            fish|FISH)
                # Install fish shell first, then fisher
                if install_fish_shell; then
                    if ! install_fish; then
                        log_error "Fisher installation failed"
                    fi
                else
                    log_error "Fish shell installation failed"
                fi
                ;;
            *)
                log_info "Leaving default shell unchanged"
                ;;
        esac
    else
        # Interactive shell selection
        while true; do
            read -rp "Install a shell? (default/zsh/fish) [default]: " shell_choice
            shell_choice=${shell_choice:-default}
            
            if validate_choice "$shell_choice" "default zsh fish ZSH FISH"; then
                break
            else
                log_error "Invalid choice. Please enter 'default', 'zsh', or 'fish'"
            fi
        done
        
        case "$shell_choice" in
            zsh|ZSH)
                if ! install_zsh; then
                    log_error "Zsh installation failed"
                fi
                ;;
            fish|FISH)
                # Install fish shell first, then fisher
                if install_fish_shell; then
                    if ! install_fish; then
                        log_error "Fisher installation failed"
                    fi
                else
                    log_error "Fish shell installation failed"
                fi
                ;;
            *)
                log_info "Leaving default shell unchanged"
                ;;
        esac
    fi
    
    # Starship installation - interactive unless non-interactive mode or specific choice specified
    if [ "$NON_INTERACTIVE" = true ] || [ "$INSTALL_STARSHIP" != "N" ]; then
        # Use command line arguments
        if [[ "$INSTALL_STARSHIP" =~ ^[Yy]$ ]]; then
            if ! install_starship; then
                log_error "Starship installation failed"
            fi
        fi
    else
        # Interactive starship selection
        while true; do
            read -rp "Install starship prompt? (y/N): " starship_choice
            starship_choice=${starship_choice:-N}
            
            if validate_choice "$starship_choice" "y Y n N"; then
                break
            else
                log_error "Invalid choice. Please enter 'y' or 'n'"
            fi
        done
        
        if [[ "$starship_choice" =~ ^[Yy]$ ]]; then
            if ! install_starship; then
                log_error "Starship installation failed"
            fi
        fi
    fi
    
    # Font installation - interactive unless non-interactive mode or specific choice specified
    if [ "$NON_INTERACTIVE" = true ] || [ "$INSTALL_FONT" != "N" ]; then
        # Use command line arguments
        if [[ "$INSTALL_FONT" =~ ^[Yy]$ ]]; then
            if ! install_nerd_font; then
                log_error "RobotoMono Nerd Font installation failed"
            fi
        fi
    else
        # Interactive font selection
        while true; do
            read -rp "Install RobotoMono Nerd Font? (y/N): " font_choice
            font_choice=${font_choice:-N}
            
            if validate_choice "$font_choice" "y Y n N"; then
                break
            else
                log_error "Invalid choice. Please enter 'y' or 'n'"
            fi
        done
        
        if [[ "$font_choice" =~ ^[Yy]$ ]]; then
            if ! install_nerd_font; then
                log_error "RobotoMono Nerd Font installation failed"
            fi
        fi
    fi
    
    # Check PATH configuration
    check_path
    
    # Verify all installations
    verify_installations
    
    log_success "Installation completed!"
    log_info "You may need to restart your shell or source your configuration file for changes to take effect."
}

# Run main function with all arguments
main "$@"
