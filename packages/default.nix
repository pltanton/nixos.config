# this is akin to a flake-parts top-level module
{ self, inputs, config, lib, ... }: {
  #imports = [{
  #  _module.args = {
  #    sharedModules = [{ nixpkgs.overlays = [ overlay-nvim ]; }];
  #  };
  #}];
  perSystem = { inputs', system, pkgs, ... }:
    let
      overlay-my-nvim = prev: final: {
        neovim-full = inputs'.my-nvim.packages.nvim-full;
        neovim-light = inputs'.my-nvim.packages.nvim-light;
      };
    in {
      # shadow the `pkgs` arg in perSystem with a new pkgs to which we add our overlays
      config._module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ overlay-my-nvim ];
      };
    };
  systems = [ "x86_64-linux" "aarch64-darwin" ];
}
# TODO:
# the /packages top level dir will define packages and install them in appr-
# opriate places; example: bring in all the code from nvim-config-flake,
# install it appropriately under overlays (so that it may be easily used by
# system configurations) and under apps so that i can use it with nix-run
# at that point I might need to change the repo name since it won't be
# just nixos anymore
