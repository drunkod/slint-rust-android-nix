{
  description = "Slint & GStreamer Android Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Optional: For Slint with Rust
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, ... }:
    let
      # Supported systems
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Helper to generate attrs for all systems
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Helper to import nixpkgs for a system
      nixpkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

    in {
      # ═══════════════════════════════════════════════════════════
      # Development Shells
      # ═══════════════════════════════════════════════════════════
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor system;
          lib = pkgs.lib;

          # Import modules helper
          mkShell = devMode:
            let
              # Import GStreamer Android module
              gstreamerAndroid =
                if devMode == "gstreamer" || devMode == "both"
                then import ./.idx/modules/gstreamer-android {
                  pkgs = pkgs;
                }
                else null;

              # Import Slint Android module
              slintAndroid =
                if devMode == "slint" || devMode == "both"
                then import ./.idx/modules/slint-android {
                  inherit pkgs lib system;
                }
                else null;

              # Import packages
              packages = import ./.idx/modules/packages.nix {
                inherit pkgs lib devMode gstreamerAndroid slintAndroid;
              };

              # Import environment
              environment = import ./.idx/modules/environment.nix {
                inherit lib devMode gstreamerAndroid slintAndroid;
              };

              # Shell hook
              shellHook = 
                if devMode == "gstreamer" && gstreamerAndroid != null
                then gstreamerAndroid.shellHook
                else if devMode == "slint" && slintAndroid != null
                then slintAndroid.shellHook
                else if devMode == "both"
                then ''
                  ${gstreamerAndroid.shellHook or ""}
                  ${slintAndroid.shellHook or ""}
                ''
                else "";

            in pkgs.mkShell {
              name = "android-dev-${devMode}";
              
              buildInputs = packages;
              
              shellHook = ''
                echo ""
                echo "╔═══════════════════════════════════════════════════╗"
                echo "║  🚀 Android Development Environment (${devMode})    "
                echo "╚═══════════════════════════════════════════════════╝"
                echo ""
                ${shellHook}
              '';
              
              # Export environment variables
              inherit (environment) 
                ANDROID_HOME 
                ANDROID_SDK_ROOT 
                ANDROID_NDK_ROOT 
                JAVA_HOME;
              
              # Additional environment from modules
              passthru = {
                inherit devMode gstreamerAndroid slintAndroid;
              };
            } // environment;

        in {
          # Default shell (Slint)
          default = mkShell "slint";
          
          # Slint-only development shell
          slint = mkShell "slint";
          
          # GStreamer-only development shell
          gstreamer = mkShell "gstreamer";
          
          # Both environments
          full = mkShell "both";
        }
      );

      # ═══════════════════════════════════════════════════════════
      # Packages (buildable outputs)
      # ═══════════════════════════════════════════════════════════
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor system;
          lib = pkgs.lib;

          # GStreamer Android build
          gstreamerAndroid = import ./.idx/modules/gstreamer-android {
            inherit pkgs;
          };

          # Slint Android module
          slintAndroid = import ./.idx/modules/slint-android {
            inherit pkgs lib system;
          };

        in {
          # Default: GStreamer Android libraries
          default = gstreamerAndroid.build;
          
          # GStreamer Android JNI libraries
          gstreamer-android-jni = gstreamerAndroid.build;
          
          # Slint Android emulator
          slint-android-emulator = slintAndroid.emulator;
          
          # All scripts
          gst-android-scripts = pkgs.buildEnv {
            name = "gst-android-scripts";
            paths = gstreamerAndroid.packages;
          };
        }
      );

      # ═══════════════════════════════════════════════════════════
      # Apps (runnable with 'nix run')
      # ═══════════════════════════════════════════════════════════
      apps = forAllSystems (system:
        let
          pkgs = nixpkgsFor system;
          lib = pkgs.lib;

          slintAndroid = import ./.idx/modules/slint-android {
            inherit pkgs lib system;
          };

          gstreamerAndroid = import ./.idx/modules/gstreamer-android {
            inherit pkgs;
          };

        in {
          # Run Slint Android emulator
          slint-emulator = {
            type = "app";
            program = "${slintAndroid.emulator}/bin/run-test-*";
          };
          
          # Show GStreamer info
          gst-info = {
            type = "app";
            program = "${pkgs.lib.findFirst (p: p.name or "" == "gst-android-info") null gstreamerAndroid.packages}/bin/gst-android-info";
          };
        }
      );

      # ═══════════════════════════════════════════════════════════
      # Formatter (for 'nix fmt')
      # ═══════════════════════════════════════════════════════════
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}
