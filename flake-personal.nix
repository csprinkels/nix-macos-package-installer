{
  description = "My Work Laptop Darwin Nix Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          pkgs.bartender
          pkgs.iina
          pkgs.mkalias
          pkgs.neovim 
          pkgs.obsidian
          pkgs.spotify
          pkgs.raycast
          pkgs.vscode
        ];

      homebrew = {
        enable = true;
        brews = [
          "mas"
        ];
        casks = [
          "adobe-creative-cloud"
          "arc"
          "cleanmymac"
          "cleanshot"
          "dropbox"
          "elgato-stream-deck"
          "elgato-wave-link"
          "github"
          "itsycal"
          "keka"
          "nordpass"
        ];
        onActivation.cleanup = "zap";
      };

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          
          # For menu bar apps, copy directly to /Applications
          if [ -e "${env}/Applications/Itsycal.app" ]; then
            echo "setting up Itsycal..." >&2
            rm -rf "/Applications/Itsycal.app"
            cp -R "${env}/Applications/Itsycal.app" "/Applications/Itsycal.app"
          fi
          
          # Set up other applications in Nix Apps folder
          rm -rf "/Applications/Nix Apps"
          mkdir -p "/Applications/Nix Apps"
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            if [ -e "$src" ] && [ "$(basename "$src")" != "Itsycal.app" ]; then
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            fi
          done
        '';

      system.defaults = {
        dock.autohide = true;
        finder.FXPreferredViewStyle = "clmv";
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."main" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "sprinkel";

            autoMigrate = true;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."main".pkgs;
  };
}
