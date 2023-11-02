{ inputs, config, lib, getSystem, moduleWithSystem, sharedModules, withSystem
, ... }:
let
  common = (import ../common { inherit lib; });
  get-secrets-for-machine = common.build-machine-secrets inputs.secrets-flake;
  overlay-nvim = prev: final: {
    neovim = inputs.my-nvim.packages.x86_64-linux.default;
  };
in {

  flake.nixosConfigurations = {
    "chani" = withSystem "x86_64-linux" (ctx@{ inputs', system, pkgs, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;

        # If you need to pass other parameters,
        # you must use `specialArgs` by uncomment the following line:
        specialArgs = {
          agenix = inputs.agenix.nixosModules.default;
          inherit (common) ssh-public-keys;
        }; # if this is missing it throws an infinite recursion er
        modules = [
          (_: { nixpkgs.pkgs = pkgs; })
          # add our pkgs with overlays
          #(_: {
          #  _module.args.pkgs =
          #    import inputs.nixpkgs { overlays = [ overlay-nvim ]; };
          #})
          #{
          #  nixpkgs.overlays = [ overlay-nvim ];
          #}
          # descrypt secrets
          ({ config, agenix, lib, ... }: {
            imports = [ agenix ];
            config = {
              age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              age.secrets = (get-secrets-for-machine "chani");
            };
            options = { };
          })
          #            (import ./modules/agenix.nix (get-secrets-for-machine "chani"))
          # {
          #              imports = [ agenix.homeManagerModules.default ];
          #              config = {
          #                age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
          #                age.secrets.secret1.file = secrets-flake.sihaya.secret1;
          #              };
          #            }
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nix Module,
          ../modules/linux-base.nix
          ./chani.nix
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to this
            home-manager.users.angel = import ../chani-angel.nix;
          }
          ../chani-secret.nix
          #./trace-test.nix
          #            (attrs: {
          #              config = builtins.trace
          #                (attrs.lib.debug.traceVal (builtins.attrNames attrs.config)) { };
          #            })
        ];
      });
    "sietch" = withSystem "x86_64-linux" (ctx@{ inputs', ... }:
      inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # If you need to pass other parameters,
        # you must use `specialArgs` by uncomment the following line:
        #
        specialArgs = {
          agenix = inputs.agenix.nixosModules.default;
          inherit (common) ssh-public-keys;
        }; # if this is missing it throws an infinite recursion err
        modules = [
          # add our pkgs with overlays
          #({ pkgs, ... }: { pkgs.overlays = [ overlay-nvim ]; })
          # descrypt secrets
          ({ config, agenix, lib, ... }: {
            imports = [ agenix ];
            config = {
              age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
              age.secrets = (get-secrets-for-machine "chani");
            };
            options = { };
          })
          #            (import ./modules/agenix.nix (get-secrets-for-machine "chani"))
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nix Module,
          ../modules/linux-base.nix
          ./sietch.nix
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # TODO replace ryan with your own username
            home-manager.users.angel = import ../sietch-angel.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      });
  };
}
