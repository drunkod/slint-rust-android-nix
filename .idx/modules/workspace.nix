# .idx/modules/workspace.nix
{ pkgs }:

{
  idx.workspace = {
    onCreate = {
      welcome = ''
        echo ""
        echo "╔═══════════════════════════════════════════════════╗"
        echo "║  🎨 Slint Android Development Environment        ║"
        echo "╚═══════════════════════════════════════════════════╝"
        echo ""
        echo "🚀 Quick Start:"
        echo "  slint-android-info       Show all commands and config"
        echo "  slint-android-build      Build APK for device"
        echo "  slint-android-run        Build and run on device"
        echo "  slint-android-install    Install APK on device"
        echo ""
        echo "📱 Note: Connect a physical device via USB for testing"
        echo "        (Emulator removed to save disk space)"
        echo ""
        echo "📖 Documentation:"
        echo "  https://slint.dev/releases/1.0/docs/rust/slint/android/"
        echo ""
      '';
    };

    onStart = {
      info = "slint-android-info";
    };
  };
}