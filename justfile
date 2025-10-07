# Run on x86_64 emulator
run:
    slint-android-run x86_64-linux-android

# Run on ARM device
run-device:
    slint-android-run aarch64-linux-android

# Build APK
build:
    slint-android-build x86_64-linux-android

# Build release APK
build-release:
    slint-android-build x86_64-linux-android release

# Start emulator
emulator:
    slint-android-emulator

# Show info
info:
    slint-android-info