{ pkgs, lib, devMode, gstreamerAndroid ? null, slintAndroid ? null }:

let
  # GStreamer packages
  gstreamerPackages =
    if gstreamerAndroid != null
    then gstreamerAndroid.packages
    else [];

  # Slint packages
  slintPackages =
    if slintAndroid != null
    then slintAndroid.packages
    else [];

  # Common packages
  commonPackages = with pkgs; [
    git
    curl
    wget
    jq
    tree
    file
    which
  ];

in
  gstreamerPackages ++ slintPackages ++ commonPackages