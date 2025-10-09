# overlays/default.nix
# Import all overlays and return as a list
[
  (import ./android.nix)
  (import ./fenix.nix)
  (import ./rust.nix)
]