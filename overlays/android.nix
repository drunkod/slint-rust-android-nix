# overlays/android.nix
final: prev: {
  # Android configuration
  androidPlatformVersion = "35";

  # Accept Android licenses
  androidEnv = prev.androidenv.override { licenseAccepted = true; };

  # Compose Android packages (minimal, no emulator/system images)
  androidComposition = final.androidEnv.composeAndroidPackages {
    cmdLineToolsVersion = "8.0";
    includeNDK = true;
    ndkVersion = "25.2.9519653";  # NDK r25c

    platformVersions = [
      "30"
      "34"
      final.androidPlatformVersion
    ];

    includeEmulator = false;
    includeSystemImages = false;

    abiVersions = [
      "armeabi-v7a"
      "arm64-v8a"
    ];

    cmakeVersions = [ "3.10.2" ];
  };

  # Android SDK (without Studio to save space)
  androidSdk = final.androidComposition.androidsdk;
}