{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nix-homebrew,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, ... }:
        {
          environment.systemPackages = with pkgs; [
            neovim
            neofetch

            nixfmt-rfc-style
          ];

          homebrew = {
            enable = true;
            brews = [
              #terminal
              "starship"
              "nushell"

              #
              "rust"
              "node"

              #misc
              "apple-music-discord-rpc"
            ];

            taps = [
              "nextfire/tap"
            ];

            casks = [
              "brave-browser"
              "linearmouse"
              "discord"
              "iina"
              "raycast"
              "iterm2"
            ];
          };

          system.defaults = {
            NSGlobalDomain = {
              InitialKeyRepeat = 10;
              KeyRepeat = 5;
              ApplePressAndHoldEnabled = false;
            };
            finder = {
              AppleShowAllExtensions = true;
              ShowHardDrivesOnDesktop = false;
              ShowExternalHardDrivesOnDesktop = false;
            };
            dock = {
              persistent-apps = [
                "/Applications/Brave Browser.app"
                "/System/Applications/Music.app"
                "/Applications/iTerm.app"
                "/Applications/Discord.app"
              ];
              minimize-to-application = true;
              show-recents = false;
              tilesize = 44;
              persistent-others = null;
            };
          };

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "x86_64-darwin";
        };
    in
    {
      darwinConfigurations."Richards-iMac-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "richard";
            };
          }
        ];
      };
    };
}