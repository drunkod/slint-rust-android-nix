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
        echo "  slint-android-run        Build and run on emulator"
        echo "  slint-android-build      Build APK"
        echo "  slint-android-emulator   Start emulator"
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