#!/bin/bash

# Dotfiles Sync Script
# Syncs configuration files between home directory and dotfiles repository

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES_DIR="/Users/im_tan/Documents/Repository/Private/dotfiles"
HOME_EMACS_DIR="$HOME/.emacs.d"

# Create dotfiles emacs directory if it doesn't exist
ensure_dotfiles_structure() {
    log_info "Ensuring dotfiles directory structure..."
    mkdir -p "$DOTFILES_DIR/.emacs.d"
    log_success "Directory structure ready"
}

# Push: Copy from home to dotfiles repository
push_to_dotfiles() {
    log_info "Pushing configuration to dotfiles repository..."
    
    # Copy init.el
    if [[ -f "$HOME_EMACS_DIR/init.el" ]]; then
        cp "$HOME_EMACS_DIR/init.el" "$DOTFILES_DIR/.emacs.d/"
        log_success "init.el copied to dotfiles"
    else
        log_warning "init.el not found in home directory"
    fi
    
    # Copy other emacs config files if they exist
    for file in early-init.el local-config.el custom.el; do
        if [[ -f "$HOME_EMACS_DIR/$file" ]]; then
            cp "$HOME_EMACS_DIR/$file" "$DOTFILES_DIR/.emacs.d/"
            log_success "$file copied to dotfiles"
        fi
    done
    
    # Commit changes
    cd "$DOTFILES_DIR"
    if git diff --quiet HEAD -- .emacs.d/; then
        log_info "No changes to commit"
    else
        git add .emacs.d/
        git commit -m "Update emacs configuration

🤖 Auto-sync from $(hostname) at $(date)

Co-Authored-By: Claude <noreply@anthropic.com>"
        log_success "Changes committed to dotfiles repository"
        
        read -p "Push to remote repository? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push
            log_success "Changes pushed to remote"
        fi
    fi
}

# Pull: Copy from dotfiles repository to home
pull_from_dotfiles() {
    log_info "Pulling configuration from dotfiles repository..."
    
    cd "$DOTFILES_DIR"
    git pull || log_warning "Could not pull latest changes"
    
    # Copy init.el
    if [[ -f "$DOTFILES_DIR/.emacs.d/init.el" ]]; then
        cp "$DOTFILES_DIR/.emacs.d/init.el" "$HOME_EMACS_DIR/"
        chmod 644 "$HOME_EMACS_DIR/init.el"
        log_success "init.el updated from dotfiles"
    else
        log_warning "init.el not found in dotfiles repository"
    fi
    
    # Copy other config files
    for file in early-init.el local-config.el custom.el; do
        if [[ -f "$DOTFILES_DIR/.emacs.d/$file" ]]; then
            cp "$DOTFILES_DIR/.emacs.d/$file" "$HOME_EMACS_DIR/"
            chmod 644 "$HOME_EMACS_DIR/$file"
            log_success "$file updated from dotfiles"
        fi
    done
}

# Initialize dotfiles with current config
init_dotfiles() {
    log_info "Initializing dotfiles with current configuration..."
    
    ensure_dotfiles_structure
    
    # Copy current init.el to dotfiles if it exists
    if [[ -f "$HOME_EMACS_DIR/init.el" ]]; then
        cp "$HOME_EMACS_DIR/init.el" "$DOTFILES_DIR/.emacs.d/"
        log_success "Current init.el copied to dotfiles"
    else
        log_warning "No init.el found in home directory"
        # Create a minimal init.el
        cat > "$DOTFILES_DIR/.emacs.d/init.el" << 'EOF'
;;; init.el --- Emacs configuration

;;; Commentary:
;; Personal Emacs configuration managed through dotfiles

;;; Code:

;; Package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Load local configuration if it exists
(when (file-exists-p "~/.emacs.d/local-config.el")
  (load "~/.emacs.d/local-config.el"))

(provide 'init)
;;; init.el ends here
EOF
        log_info "Created minimal init.el"
    fi
    
    # Initial commit
    cd "$DOTFILES_DIR"
    if ! git diff --quiet HEAD -- .emacs.d/ 2>/dev/null; then
        git add .emacs.d/
        git commit -m "Initialize emacs configuration in dotfiles

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
        log_success "Initial emacs configuration committed"
    fi
}

# Show status
show_status() {
    log_info "Configuration Status:"
    echo
    
    echo "📁 Home Directory:"
    ls -la "$HOME_EMACS_DIR"/{init.el,early-init.el,local-config.el} 2>/dev/null || echo "  No config files found"
    echo
    
    echo "📁 Dotfiles Repository:"
    ls -la "$DOTFILES_DIR/.emacs.d"/{init.el,early-init.el,local-config.el} 2>/dev/null || echo "  No config files found"
    echo
    
    if [[ -d "$DOTFILES_DIR/.git" ]]; then
        cd "$DOTFILES_DIR"
        echo "🔄 Git Status:"
        git status --porcelain .emacs.d/ | sed 's/^/  /'
    fi
}

# Main function
main() {
    case "${1:-help}" in
        "push"|"p")
            ensure_dotfiles_structure
            push_to_dotfiles
            ;;
        "pull"|"pl")
            pull_from_dotfiles
            ;;
        "init"|"i")
            init_dotfiles
            ;;
        "status"|"s")
            show_status
            ;;
        "help"|"h"|*)
            echo "Dotfiles Sync Script"
            echo
            echo "Usage: $0 [command]"
            echo
            echo "Commands:"
            echo "  push, p     - Push configuration to dotfiles repository"
            echo "  pull, pl    - Pull configuration from dotfiles repository"
            echo "  init, i     - Initialize dotfiles with current configuration"
            echo "  status, s   - Show configuration status"
            echo "  help, h     - Show this help"
            echo
            echo "Workflow:"
            echo "  1. Edit ~/.emacs.d/init.el"
            echo "  2. Run './sync-dotfiles.sh push' to save to dotfiles"
            echo "  3. Run 'hm-switch' to apply Home Manager configuration"
            ;;
    esac
}

main "$@"