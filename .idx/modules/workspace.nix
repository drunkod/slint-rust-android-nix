# .idx/modules/workspace.nix
{ pkgs, devMode }:

let
  gstreamerWelcome = ''
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║  🎬 GStreamer Android Build Environment          ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    echo "Commands:"
    echo "  gst-android-info       Show build configuration"
    echo "  gst-android-build      Build Android artifacts"
    echo "  gst-android-test       Test the build"
    echo "  gst-android-deploy     Deploy to Android project"
    echo ""
  '';

  slintWelcome = ''
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║  🎨 Slint Android Development Environment        ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    echo "Commands:"
    echo "  slint-android-run        Run on emulator/device"
    echo "  slint-android-build      Build APK"
    echo "  slint-android-emulator   Start emulator"
    echo "  slint-android-info       Show help"
    echo ""
  '';

  bothWelcome = ''
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║  🚀 Android Development Environment (Full)       ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    echo "🎬 GStreamer Commands:"
    echo "  gst-android-*"
    echo ""
    echo "🎨 Slint Commands:"
    echo "  slint-android-*"
    echo ""
    echo "Run 'gst-android-info' or 'slint-android-info' for details"
    echo ""
  '';

  welcomeMessage =
    if devMode == "gstreamer" then gstreamerWelcome
    else if devMode == "slint" then slintWelcome
    else if devMode == "both" then bothWelcome
    else "Development environment ready!";

in {
  idx.workspace = {
    onCreate = {
      welcome = welcomeMessage;
    };

    onStart = {
      info =
        if devMode == "gstreamer" then "gst-android-info"
        else if devMode == "slint" then "slint-android-info"
        else "echo 'Run gst-android-info or slint-android-info'";
    };
  };
}