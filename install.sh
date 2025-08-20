#!/bin/bash

# nixos-config Installation Script
# This script installs Nix, Home Manager, applies configuration, and makes init.el editable

set -e  # Exit on any error

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

# Check if running on macOS
check_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS. For Linux, use the Linux configuration."
        exit 1
    fi
    log_info "Detected macOS"
}

# Install Nix if not already installed
install_nix() {
    log_info "Checking for Nix installation..."
    
    if command -v nix >/dev/null 2>&1; then
        log_success "Nix is already installed"
        return 0
    fi
    
    log_info "Installing Nix package manager..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source nix profile
    if [[ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]]; then
        source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    fi
    
    log_success "Nix installed successfully"
}

# Enable flakes and nix-command
configure_nix() {
    log_info "Configuring Nix with flakes support..."
    
    mkdir -p ~/.config/nix
    cat > ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
EOF
    
    log_success "Nix configuration updated"
}

# Install and configure Home Manager
install_home_manager() {
    log_info "Installing Home Manager..."
    
    # Apply Home Manager configuration
    log_info "Applying Home Manager configuration..."
    nix run nixpkgs#home-manager -- switch --flake .#darwin -b backup
    
    log_success "Home Manager configured successfully"
}

# Fix init.el to be editable
fix_init_el() {
    log_info "Making init.el editable..."
    
    INIT_EL="$HOME/.emacs.d/init.el"
    
    if [[ -L "$INIT_EL" ]]; then
        log_info "Removing symlink and creating editable copy..."
        
        # Get the target of the symlink
        TARGET=$(readlink "$INIT_EL")
        
        # Remove symlink and copy content
        rm "$INIT_EL"
        cp "$TARGET" "$INIT_EL"
        chmod 644 "$INIT_EL"
        
        log_success "init.el is now editable"
    else
        log_warning "init.el is not a symlink, checking permissions..."
        chmod 644 "$INIT_EL" 2>/dev/null || true
    fi
}

# Setup Fish shell configuration
setup_shell() {
    log_info "Setting up Fish shell..."
    
    # Add fish to /etc/shells if not already there
    if ! grep -q "$(which fish)" /etc/shells 2>/dev/null; then
        echo "$(which fish)" | sudo tee -a /etc/shells >/dev/null
        log_info "Added Fish to /etc/shells"
    fi
    
    # Change default shell to fish
    if [[ "$SHELL" != *"fish"* ]]; then
        log_info "Changing default shell to Fish..."
        chsh -s "$(which fish)"
        log_warning "Please restart your terminal or run 'exec fish' to use the new shell"
    fi
    
    log_success "Shell configuration complete"
}

# Create useful aliases and functions
create_aliases() {
    log_info "Creating useful aliases..."
    
    cat >> ~/.config/fish/config.fish << 'EOF'

# Auto-generated aliases for nixos-config management
alias hm-switch='nix run nixpkgs#home-manager -- switch --flake .#darwin -b backup'
alias hm-news='home-manager news'
alias nixos-config='cd ~/Documents/Repository/Private/nixos-config'
alias fix-emacs='~/Documents/Repository/Private/nixos-config/fix-emacs.sh'
EOF
    
    log_success "Aliases created"
}

# Create helper script for fixing emacs
create_fix_emacs_script() {
    log_info "Creating fix-emacs helper script..."
    
    cat > ./fix-emacs.sh << 'EOF'
#!/bin/bash
# Helper script to fix init.el symlink issue

INIT_EL="$HOME/.emacs.d/init.el"

if [[ -L "$INIT_EL" ]]; then
    echo "Fixing init.el symlink..."
    TARGET=$(readlink "$INIT_EL")
    rm "$INIT_EL"
    cp "$TARGET" "$INIT_EL"
    chmod 644 "$INIT_EL"
    echo "init.el is now editable"
else
    echo "init.el is already a regular file"
    chmod 644 "$INIT_EL" 2>/dev/null || true
fi
EOF
    
    chmod +x ./fix-emacs.sh
    log_success "fix-emacs.sh script created"
}

# Main installation function
main() {
    log_info "Starting nixos-config installation..."
    echo "================================"
    
    # Change to script directory
    cd "$(dirname "$0")"
    
    check_os
    install_nix
    configure_nix
    install_home_manager
    fix_init_el
    setup_shell
    create_aliases
    create_fix_emacs_script
    
    echo "================================"
    log_success "Installation completed successfully!"
    echo ""
    log_info "What's next:"
    echo "  1. Restart your terminal or run 'exec fish'"
    echo "  2. Your Emacs init.el is now editable at ~/.emacs.d/init.el"
    echo "  3. Use 'hm-switch' to apply Home Manager changes"
    echo "  4. Use 'fix-emacs' if init.el becomes read-only again"
    echo ""
    log_warning "Note: If you run 'hm-switch', init.el will become a symlink again."
    log_warning "Use the 'fix-emacs' command to make it editable after Home Manager changes."
}

# Run main function
main "$@"