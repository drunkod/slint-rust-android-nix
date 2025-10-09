# .idx/modules/slint-android/default.nix
{ pkgs, lib, system }:

let
  # Use overlayed packages
  platformVersion = pkgs.androidPlatformVersion;
  androidComposition = pkgs.androidComposition;
  android-sdk = pkgs.androidSdk;
  rustToolchain = pkgs.rustToolchain;

  currentPath = builtins.getEnv "PWD";

  # Helper scripts
  runAndroidScript = pkgs.writeShellScriptBin "slint-android-run" ''
    #!/usr/bin/env bash
    set -euo pipefail

    TARGET="''${1:-aarch64-linux-android}"

    echo "🚀 Building and running Slint Android app..."
    echo "   Target: $TARGET"
    echo ""
    echo "📱 Make sure your device is connected via ADB"
    echo ""

    cargo apk run --target "$TARGET" --lib
  '';

  buildApkScript = pkgs.writeShellScriptBin "slint-android-build" ''
    #!/usr/bin/env bash
    set -euo pipefail

    TARGET="''${1:-aarch64-linux-android}"
    MODE="''${2:-debug}"

    echo "🔨 Building Slint Android APK..."
    echo "   Target: $TARGET"
    echo "   Mode: $MODE"
    echo ""

    if [ "$MODE" = "release" ]; then
      cargo apk build --target "$TARGET" --lib --release
    else
      cargo apk build --target "$TARGET" --lib
    fi

    echo ""
    echo "✅ APK built successfully!"
    find target -name "*.apk" -type f | head -5
  '';

  installApkScript = pkgs.writeShellScriptBin "slint-android-install" ''
    #!/usr/bin/env bash
    set -euo pipefail

    APK_PATH="''${1:-}"

    if [ -z "$APK_PATH" ]; then
      echo "📱 Looking for APK files..."
      APK_PATH=$(find target -name "*.apk" -type f | head -1)
    fi

    if [ -z "$APK_PATH" ] || [ ! -f "$APK_PATH" ]; then
      echo "❌ No APK file found. Build one first with 'slint-android-build'"
      exit 1
    fi

    echo "📱 Installing APK: $APK_PATH"
    adb install -r "$APK_PATH"
  '';

  infoScript = pkgs.writeShellScriptBin "slint-android-info" ''
    #!/usr/bin/env bash
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  🎨 Slint Android Development Environment     ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""
    echo "📦 Configuration:"
    echo "   Platform: Android ${platformVersion}"
    echo "   SDK: $ANDROID_HOME"
    echo "   NDK: $ANDROID_NDK_ROOT"
    echo "   Java: $JAVA_HOME"
    echo "   Rust: $(rustc --version 2>/dev/null || echo 'N/A')"
    echo ""
    echo "🎯 Targets:"
    echo "   • aarch64-linux-android (ARM64 devices)"
    echo "   • armv7-linux-androideabi (ARM devices)"
    echo ""
    echo "🛠️  Commands:"
    echo "   slint-android-build [target] [mode]   Build APK"
    echo "   slint-android-run [target]            Build and run on device"
    echo "   slint-android-install [apk]           Install APK on device"
    echo "   slint-android-info                    Show this info"
    echo ""
    echo "📖 Examples:"
    echo "   slint-android-build                              # Debug build for ARM64"
    echo "   slint-android-build aarch64-linux-android release # Release build"
    echo "   slint-android-run aarch64-linux-android          # Run on ARM64 device"
    echo "   slint-android-install target/debug/apk/*.apk     # Install specific APK"
    echo ""
    echo "📱 Device Connection:"
    echo "   adb devices                          # List connected devices"
    echo "   adb logcat                          # View device logs"
    echo ""
  '';

in {
  packages = [
    rustToolchain
    pkgs.cargo-apk
    pkgs.jdk17
    android-sdk
    pkgs.android-tools  # For adb
    buildApkScript
    runAndroidScript
    installApkScript
    infoScript
  ];

  env = {
    ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
    ANDROID_NDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk/ndk-bundle";
    JAVA_HOME = "${pkgs.jdk17}";

    CARGO_HOME = "${currentPath}/.cargo-home";

    LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
      wayland
      libxkbcommon
      fontconfig
    ]);
  };

  inherit androidComposition;

  shellHook = ''
    if [ -z "$_SLINT_ANDROID_INIT" ]; then
      export _SLINT_ANDROID_INIT=1
      echo "🎨 Slint Android environment ready!"
      echo "   Run 'slint-android-info' for help"
      echo ""
      echo "📱 Note: Emulator removed to save space."
      echo "   Connect a physical device via USB for testing."
    fi
  '';
}