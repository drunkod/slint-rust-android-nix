# overlays/rust.nix
final: prev: {
  # Rust toolchain with Android targets using Fenix
  rustToolchain = final.fenixPkgs.combine [
    final.fenixPkgs.stable.toolchain
    final.fenixPkgs.targets.aarch64-linux-android.stable.rust-std
    final.fenixPkgs.targets.armv7-linux-androideabi.stable.rust-std
  ];
}