# Run on connected device (aarch64)
run:
    slint-android-run aarch64-linux-android

# Build debug APK for device (aarch64)
build:
    slint-android-build aarch64-linux-android

# Build release APK for device (aarch64)
build-release:
    slint-android-build aarch64-linux-android release

# Install latest built APK to device
install:
    slint-android-install

# Show info
info:
    slint-android-info