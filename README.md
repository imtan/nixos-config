# nixos-config

Personal NixOS and macOS configuration using Home Manager and Nix Flakes.

## Quick Installation

For a fresh system setup:

```bash
git clone https://github.com/yourusername/nixos-config.git
cd nixos-config
./install.sh
```

The installation script will:
- Install Nix package manager
- Configure Nix with flakes support  
- Install and apply Home Manager configuration
- Fix Emacs init.el to be editable
- Setup Fish shell with useful aliases

## Manual Installation

If you prefer manual installation:

### 1. Install Nix
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Enable Flakes
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

### 3. Apply Home Manager Configuration
```bash
nix run nixpkgs#home-manager -- switch --flake .#darwin -b backup
```

### 4. Fix Emacs Configuration
```bash
./fix-emacs.sh
```

## Usage

### Useful Commands

- `hm-switch` - Apply Home Manager configuration changes
- `fix-emacs` - Fix init.el symlink to make it editable
- `hm-news` - View Home Manager news

### Making Changes

1. Edit configuration files in this repository
2. Run `hm-switch` to apply changes
3. If init.el becomes read-only, run `fix-emacs`

## Configuration Structure

- `flake.nix` - Main flake configuration
- `home.nix` - Home Manager configuration
- `configuration-darwin.nix` - macOS-specific configuration
- `install.sh` - Automated installation script
- `fix-emacs.sh` - Helper script for Emacs configuration

## Emacs Configuration

The Emacs init.el file is managed through Home Manager but made editable after installation. When you run `hm-switch`, it will become a read-only symlink again. Use the `fix-emacs` command to make it editable.

## Troubleshooting

### init.el is Read-Only
This happens because Home Manager creates symlinks to the Nix store. Run:
```bash
./fix-emacs.sh
```

### Shell Not Changed to Fish
Restart your terminal or run:
```bash
exec fish
```