# .idx/modules/environment.nix
{ pkgs, lib }:

let
  currentPath = builtins.getEnv "PWD";
in
{
  # Basic environment variables
  # Android and Rust envs will be set when slint-android is loaded

  # Optional: Uncomment to always have Android/Rust available
  # ANDROID_HOME = "${pkgs.androidSdk}/libexec/android-sdk";
  # ANDROID_SDK_ROOT = "${pkgs.androidSdk}/libexec/android-sdk";
  # ANDROID_NDK_ROOT = "${pkgs.androidSdk}/libexec/android-sdk/ndk-bundle";
  # JAVA_HOME = "${pkgs.jdk17}";

  # Common paths
  CARGO_HOME = "${currentPath}/.cargo-home";

  # Library path for GUI development
  LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
    wayland
    libxkbcommon
    fontconfig
  ]);
}