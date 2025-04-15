{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fish
    emacs
    git
  ];

  environment.variables = {
    EDITOR = "emacs";
  };

  programs.fish.enable = true;
  system.stateVersion = "24.11";

}

