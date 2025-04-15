{ config, pkgs, dotfiles, ... }:

{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
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
    '';
  };

  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
  };
  programs.man.enable = true;
  home.packages = with pkgs; [
    fish starship git nodejs cmigemo
  ];
  home.file.".emacs.d/init.el".source = dotfiles  + "/.emacs.d/init.el";
  home.file.".emacs.d/init-linux.el".source = dotfiles + "/.emacs.d/init-linux.el";
  home.file.".emacs.d/ddskk".source = dotfiles + "/.emacs.d/ddskk";
  home.file.".emacs.d/skk-get-jisyo".source = dotfiles + "/.emacs.d/skk-get-jisyo";

  home.stateVersion = "24.11";
}

