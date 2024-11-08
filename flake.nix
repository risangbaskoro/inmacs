{
  description = "Personal Darwin Intel system flake";

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
            # CLI Tools
            pkgs.mkalias
            pkgs.tree
            pkgs.fzf
            pkgs.stow
            pkgs.delta
            pkgs.neovim
            pkgs.ripgrep
            pkgs.tmux
            pkgs.gnupg
            pkgs.cmake
            pkgs.conan
            pkgs.pinentry_mac
            pkgs.gh
            pkgs.librespeed-cli
            pkgs.python3

            # GUI Apps
            pkgs.alacritty
            pkgs.obsidian
            pkgs.net-news-wire
            pkgs.raycast
          ];

        homebrew = {
          enable = true;
          brews = [
            "mas"
          ];
          casks = [
            "hyperkey"
            "zotero"
          ];
          onActivation.cleanup = "zap";
          onActivation.autoUpdate = true;
          onActivation.upgrade = true;
        };

        fonts.packages = [
          (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; })
        ];

        system.activationScripts.applications.text =
          let
            env = pkgs.buildEnv {
              name = "system-applications";
              paths = config.environment.systemPackages;
              pathsToLink = "/Applications";
            };
          in
          pkgs.lib.mkForce ''
            # Set up applications.
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read src; do
              app_name=$(basename "$src")
              echo "aliasing $src to /Applications/Nix Apps/$app_name" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
          '';


        system.defaults = {
          dock.autohide = true;
          dock.persistent-apps = [
            "/System/Applications/Launchpad.app"
            "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
            "/System/Applications/Messages.app"
            "/System/Applications/Mail.app"
            "/System/Applications/Music.app"
            "${pkgs.obsidian}/Applications/Obsidian.app"
          ];
          loginwindow.GuestEnabled = false;
          NSGlobalDomain.KeyRepeat = 2;
        };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true; # default shell on catalina
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
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."laptop" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "risangbaskoro";
              autoMigrate = true;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."laptop".pkgs;
    };
}
