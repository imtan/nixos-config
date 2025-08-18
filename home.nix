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
      alias sync-init='cp ~/.emacs.d/init.el ~/Documents/Repository/Private/dotfiles/.emacs.d/ && cd ~/Documents/Repository/Private/dotfiles && git add .emacs.d/init.el'
    '';
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
  };
  programs.man.enable = true;
  home.packages = with pkgs; [
    fish starship git nodejs cmigemo claude-code
  ];
  home.file.".emacs.d/init.el" = {
    source = dotfiles + "/.emacs.d/init.el";
    recursive = false;
  };
  home.file.".emacs.d/init-linux.el" = {
    source = dotfiles + "/.emacs.d/init-linux.el";
    recursive = false;
  };
  home.file.".emacs.d/ddskk" = {
    source = dotfiles + "/.emacs.d/ddskk";
    recursive = true;
  };
  home.file.".emacs.d/skk-get-jisyo" = {
    source = dotfiles + "/.emacs.d/skk-get-jisyo";
    recursive = true;
  };

  home.stateVersion = "24.11";
}

