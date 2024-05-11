# this is akin to a flake-parts top-level module
{ inputs, config, lib, getSystem, moduleWithSystem, privateModules, withSystem
, ... }:
let
  sharedModules = config.flake.nixosModules;
  secretsModule = (import ./modules/secrets.nix inputs.secrets-flake
    inputs.agenix.nixosModules.default sharedModules.lockbox);
in {
  flake.nixosConfigurations = {
    "sietch" = withSystem "x86_64-linux" (ctx@{ inputs', system, pkgs, ... }:
      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [{ nixpkgs.pkgs = pkgs; }] ++ privateModules ++ [
          #shared-modules.agenix
          secretsModule
          sharedModules.linux-base
          ./modules/soft-serve
          (import ./configuration.nix config.flake.lib)
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # TODO replace ryan with your own username
            home-manager.users.angel = import config.flake.homeModules.angel;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      });
  };
}

