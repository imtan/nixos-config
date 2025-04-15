{
  description = "My NixOS and Darwin flake setup with Fish and Emacs (Darwin is aarch64)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # 既存の NixOS-WSL 用モジュール
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    # Darwin 用のモジュール（nix-darwin）
    darwin.url = "github:lnl7/nix-darwin/master";
    dotfiles = {
      url = "git+ssh://git@github.com/imtan/dotfiles?ref=main";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-wsl, darwin, dotfiles, ... }:
    let
      # NixOS 用システム（WSL/NixOS 等）の場合
      linuxSystem = "x86_64-linux";
      # Darwin 用システム（Apple Silicon; macOS on M1/M2等）を Aarch 用に指定
      darwinSystem = "aarch64-darwin";
      dotfilesPath = builtins.path {
        name = "dotfiles";
        path = dotfiles;
      };
    in rec {
      # --- NixOS 用設定 ---
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        modules = [
          # WSL 用固有設定（不要な場合は除外）
          nixos-wsl.nixosModules.wsl
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.nixos = { config, pkgs, ... }:
              import ./home.nix {
                inherit config pkgs;
                dotfiles = dotfilesPath;
              };
          }
        ];
        specialArgs = { dotfiles = dotfilesPath; };
      };

      # --- Darwin 用設定 (nix-darwin) ---
      darwinConfigurations.myDarwin = darwin.lib.darwinSystem {
        system = darwinSystem;
        modules = [
          # Darwin 固有のシステム設定。WSL/NixOS 固有の設定は削除または置換してください。
          ./configuration-darwin.nix
        ];
      };
      # --- Home Manager 設定（共通） ---
      homeConfigurations.nixos = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = linuxSystem; };
        extraSpecialArgs = { dotfiles = dotfilesPath; };
        modules = [ ./home.nix ];
      };

      homeConfigurations.darwin = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = darwinSystem; };
        extraSpecialArgs = { dotfiles = dotfilesPath; };
        modules = [ ./home.nix ];
      };
    };
}