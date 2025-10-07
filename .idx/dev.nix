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

  # Import Slint Android module
  slintAndroid = import ./modules/slint-android {
    pkgs = pkgsWithUnfree;
    inherit lib system;
  };

  # Import other modules
  packages = import ./modules/packages.nix {
    pkgs = pkgsWithUnfree;
    inherit lib slintAndroid;
  };

  environment = import ./modules/environment.nix {
    inherit lib slintAndroid;
  };

  previews = import ./modules/previews.nix {
    pkgs = pkgsWithUnfree;
  };

  workspace = import ./modules/workspace.nix {
    pkgs = pkgsWithUnfree;
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
  
  # Export emulator package
  # idx.packages = {
  #   slint-android-emulator = slintAndroid.emulator;
  # };
}