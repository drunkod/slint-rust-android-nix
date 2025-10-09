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

  # Import modules (without slint-android auto-loading)
  packages = import ./modules/packages.nix {
    pkgs = extendedPkgs;
    inherit lib;
  };

  environment = import ./modules/environment.nix {
    pkgs = extendedPkgs;
    inherit lib;
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
      packages = packages;
      env = environment;
    }
    previews
    workspace
  ];
}