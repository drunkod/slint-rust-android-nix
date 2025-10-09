# .idx/dev.nix
{ pkgs, lib, config, ... }:

let
  system = pkgs.stdenv.system;

  # ═══════════════════════════════════════════════════════════════════
  # Apply overlays
  # ═══════════════════════════════════════════════════════════════════
  overlays = import ./overlays/default.nix;

  # Apply overlays to pkgs
  extendedPkgs = builtins.foldl' (p: overlay: p.extend overlay) pkgs overlays;

  # Import Slint Android module with extended pkgs
  slintAndroid = import ./modules/slint-android {
    pkgs = extendedPkgs;
    inherit lib system;
  };

  # Import packages
  # packages = import ./modules/packages.nix {
  #   pkgs = extendedPkgs;
  #   inherit lib slintAndroid;
  # };

  environment = import ./modules/environment.nix {
    inherit lib slintAndroid;
  };

  previews = import ./modules/previews.nix {
    pkgs = extendedPkgs;
  };

  workspace = import ./modules/workspace.nix {
    pkgs = extendedPkgs;
  };

in {
  imports = [
    {
      channel = "stable-25.05";
      # packages = packages;
      env = environment;
    }
    previews
    workspace
  ];
}