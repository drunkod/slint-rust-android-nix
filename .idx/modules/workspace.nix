# .idx/modules/workspace.nix
{ pkgs }:

{
  idx.workspace = {
    onCreate = {
      welcome = ''
        echo ""
        echo "╔═══════════════════════════════════════════════════╗"
        echo "║     🚀 Development Environment Ready              ║"
        echo "╚═══════════════════════════════════════════════════╝"
        echo ""
        echo "📦 Overlays loaded:"
        echo "  ✓ Android SDK (${pkgs.androidPlatformVersion})"
        echo "  ✓ Rust Toolchain (with Android targets)"
        echo "  ✓ Fenix"
        echo ""
        echo "🔧 To enable Slint Android development:"
        echo "  1. Run: nix develop .#slint"
        echo "  2. Or load manually in your shell"
        echo ""
        echo "📖 Available commands after loading Slint:"
        echo "  slint-android-info       Show all commands"
        echo "  slint-android-build      Build APK"
        echo "  slint-android-run        Build and run on device"
        echo ""
      '';
    };

    onStart = {
      info = ''
        echo "💡 Tip: Load Slint Android tools with 'nix develop .#slint'"
      '';
    };
  };
}