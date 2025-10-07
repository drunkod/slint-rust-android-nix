{ lib, devMode, gstreamerAndroid ? null, slintAndroid ? null }:

let
  # GStreamer environment
  gstreamerEnv =
    if gstreamerAndroid != null
    then gstreamerAndroid.env
    else {};

  # Slint environment
  slintEnv =
    if slintAndroid != null
    then slintAndroid.env
    else {};

in
  lib.mkMerge [
    gstreamerEnv
    slintEnv
  ]