# .idx/modules/packages.nix
{ pkgs, lib }:

let
  # Base development packages (overlays provide androidSdk, rustToolchain, etc.)
  basePackages = with pkgs; [
    # Overlayed packages (available but not in buildInputs by default)
    # rustToolchain
    # androidSdk
    # fenixPkgs

    # Common development tools
    git
    curl
    wget
    jq
    tree
    file
    which
    ripgrep
    fd
    bat

    # Basic build tools
    gcc
    gnumake
    pkg-config
  ];

in
  basePackages