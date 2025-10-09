# .idx/scripts/enable-slint.nix
# Load this with: nix-shell .idx/scripts/enable-slint.nix
{ pkgs ? import <nixpkgs> {} }:

let
  overlays = import ../overlays/default.nix;
  extendedPkgs = builtins.foldl' (p: overlay: p.extend overlay) pkgs overlays;

  slintAndroid = import ../modules/slint-android {
    pkgs = extendedPkgs;
    lib = pkgs.lib;
    system = pkgs.stdenv.system;
  };

in pkgs.mkShell ({
  buildInputs = slintAndroid.packages;
  shellHook = slintAndroid.shellHook;
} // slintAndroid.env)