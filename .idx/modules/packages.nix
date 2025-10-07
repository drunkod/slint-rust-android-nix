{ pkgs, lib, slintAndroid }:

let
  # Slint packages
  slintPackages = slintAndroid.packages;

  # Common development packages
  commonPackages = with pkgs; [
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
  ];

in
  slintPackages ++ commonPackages