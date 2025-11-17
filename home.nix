{ config, pkgs, dotfiles, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  username = if isDarwin then "im_tan" else "nixos";
  homeDirectory = if isDarwin then "/Users/im_tan" else "/home/nixos";
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;
  #home.file.".config/starship.toml".source = dotfiles + "/.config/starship.toml";
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set -gx EDITOR emacs
      set -gx STARSHIP_CONFIG ~/.config/starship.toml
      starship init fish | source
      # Liminal aesthetic alias
      alias la='eza -la --color=always --group-directories-first'
      alias ..='cd ..'
      set -g theme_color_scheme gruvbox

      # Home Manager aliases
      alias hm-switch='nix run nixpkgs#home-manager -- switch --flake .#darwin -b backup'
      alias hm-news='home-manager news'

      # Dotfiles management
      alias dotfiles='cd ~/Documents/Repository/Private/dotfiles'
      alias emacs-config='cd ~/.emacs.d'
      alias nixos-config='cd ~/Documents/Repository/Private/nixos-config'

      # Sync scripts
      alias sync-dotfiles='~/Documents/Repository/Private/nixos-config/sync-dotfiles.sh'
      alias sync-push='~/Documents/Repository/Private/nixos-config/sync-dotfiles.sh push'
      alias sync-pull='~/Documents/Repository/Private/nixos-config/sync-dotfiles.sh pull'
      alias sync-status='~/Documents/Repository/Private/nixos-config/sync-dotfiles.sh status'
    '';
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
  };
  programs.man.enable = true;
  home.packages = with pkgs; [
    fish starship git nodejs cmigemo claude-code copilot-language-server
  ];
  home.stateVersion = "24.11";
}

