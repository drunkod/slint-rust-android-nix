{ pkgs, androidEnv, platformVersion, systemImageType }:

androidEnv.emulateApp {
  name = "slint-android-emulator";
  platformVersion = platformVersion;
  abiVersion = "x86_64";  # Use host architecture
  systemImageType = systemImageType;

  # Optional: Configure emulator settings
  # avdHomeDir = "$HOME/.android/avd";
  # enableGPU = true;
}