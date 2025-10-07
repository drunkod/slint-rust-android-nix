{ pkgs, lib, system }:

let
  # Android configuration
  platformVersion = "35";
  systemImageType = "default";
  currentPath = builtins.getEnv "PWD";

  # Accept Android licenses
  androidEnv = pkgs.androidenv.override { licenseAccepted = true; };

  # Compose Android packages
  androidComposition = androidEnv.composeAndroidPackages {
    cmdLineToolsVersion = "8.0";
    includeNDK = true;

    # Platform versions
    platformVersions = [
      "30"
      "34"
      platformVersion
    ];

    # Emulator and system images
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [
      systemImageType
      # "google_apis"
    ];

    # Target architectures
    abiVersions = [
      "x86"
      "x86_64"
      "armeabi-v7a"
      "arm64-v8a"
    ];

    cmakeVersions = [ "3.10.2" ];
  };

  # Android SDK with Studio
  android-sdk = pkgs.android-studio.withSdk androidComposition.androidsdk;

  # Import emulator configuration
  emulator = import ./emulator.nix {
    inherit pkgs androidEnv platformVersion systemImageType;
  };

  # Rust toolchain with Android targets
  fenix = pkgs.callPackage (builtins.fetchGit {
    url = "https://github.com/nix-community/fenix";
    rev = "main";
  }) { };

  rustToolchain = fenix.combine [
    fenix.stable.toolchain
    fenix.targets.aarch64-linux-android.stable.rust-std
    fenix.targets.x86_64-linux-android.stable.rust-std
  ];

  # Helper scripts
  runAndroidScript = pkgs.writeShellScriptBin "slint-android-run" ''
    #!/usr/bin/env bash
    set -euo pipefail

    TARGET="''${1:-x86_64-linux-android}"

    echo "🚀 Building and running Slint Android app..."
    echo "   Target: $TARGET"
    echo ""

    cargo apk run --target "$TARGET" --lib
  '';

  buildApkScript = pkgs.writeShellScriptBin "slint-android-build" ''
    #!/usr/bin/env bash
    set -euo pipefail

    TARGET="''${1:-x86_64-linux-android}"
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

  emulatorScript = pkgs.writeShellScriptBin "slint-android-emulator" ''
    #!/usr/bin/env bash
    echo "📱 Starting Android emulator..."
    nix run .#slint-android-emulator
  '';

  infoScript = pkgs.writeShellScriptBin "slint-android-info" ''
    #!/usr/bin/env bash
    echo ""
    echo "╔════════════════════════════════════════════════╗"
    echo "║  🎨 Slint Android Development Environment     ║"
    echo "╚════════════════════════════════════════════════╝"
    echo ""
    echo "📦 Configuration:"
    echo "   Platform: Android ${platformVersion} (${systemImageType})"
    echo "   SDK: $ANDROID_HOME"
    echo "   NDK: $ANDROID_NDK_ROOT"
    echo "   Java: $JAVA_HOME"
    echo ""
    echo "🎯 Targets:"
    echo "   • x86_64-linux-android (emulator)"
    echo "   • aarch64-linux-android (device)"
    echo ""
    echo "🛠️  Commands:"
    echo "   slint-android-run [target]     Run on emulator/device"
    echo "   slint-android-build [target]   Build APK"
    echo "   slint-android-emulator         Start emulator"
    echo "   slint-android-info             Show this info"
    echo ""
    echo "📖 Examples:"
    echo "   slint-android-run              # Run on x86_64 emulator"
    echo "   slint-android-run aarch64      # Run on device"
    echo "   slint-android-build x86_64     # Build for emulator"
    echo ""
  '';

in {
  # Packages to install
  packages = [
    rustToolchain
    pkgs.cargo-apk
    pkgs.jdk17
    android-sdk
    runAndroidScript
    buildApkScript
    emulatorScript
    infoScript
  ];

  # Environment variables
  env = {
    ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
    ANDROID_NDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk/ndk-bundle";
    JAVA_HOME = "${pkgs.jdk17}";

    # Rust cargo home (isolated)
    CARGO_HOME = "${currentPath}/.cargo-home";

    # Library paths for Linux
    LD_LIBRARY_PATH = lib.makeLibraryPath (with pkgs; [
      wayland
      libxkbcommon
      fontconfig
    ]);
  };

  # Export for use in other modules
  inherit androidComposition emulator;

  # Shell hook
  shellHook = ''
    if [ -z "$_SLINT_ANDROID_INIT" ]; then
      export _SLINT_ANDROID_INIT=1
      echo "🎨 Slint Android environment ready!"
      echo "   Run 'slint-android-info' for help"
    fi
  '';
}