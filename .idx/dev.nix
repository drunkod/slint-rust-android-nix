# .idx/dev.nix
{ pkgs, lib, config, ... }:

let
  system = pkgs.stdenv.system;

  # Import nixpkgs with unfree packages allowed
  pkgsWithUnfree = import pkgs.path {
    inherit system;
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };

  # ═══════════════════════════════════════════════════════════
  # Choose your development mode:
  # - "gstreamer" for GStreamer Android development
  # - "slint" for Slint Android development
  # - "both" for both environments
  # ═══════════════════════════════════════════════════════════
  devMode = "slint";  # Change this to switch modes

  # Import GStreamer Android module
  gstreamerAndroid =
    if devMode == "gstreamer" || devMode == "both"
    then import ./modules/gstreamer-android {
      pkgs = pkgsWithUnfree;
    }
    else null;

  # Import Slint Android module
  slintAndroid =
    if devMode == "slint" || devMode == "both"
    then import ./modules/slint-android {
      pkgs = pkgsWithUnfree;
      inherit lib system;
    }
    else null;

  # Import other modules
  packages = import ./modules/packages.nix {
    pkgs = pkgsWithUnfree;
    inherit lib devMode gstreamerAndroid slintAndroid;
  };

  environment = import ./modules/environment.nix {
    inherit lib devMode gstreamerAndroid slintAndroid;
  };

  previews = import ./modules/previews.nix {
    pkgs = pkgsWithUnfree;
  };

  workspace = import ./modules/workspace.nix {
    pkgs = pkgsWithUnfree;
    inherit devMode;
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

  # Export emulator package if using Slint
  idx.packages = lib.optionalAttrs (devMode == "slint" || devMode == "both") {
    slint-android-emulator = slintAndroid.emulator;
  };
}