{
  description = "Development Environment with Manual Slint Loading";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      nixpkgsFor = system: import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          android_sdk.accept_license = true;
        };
      };

    in {
      # Development Shells
      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor system;
          lib = pkgs.lib;

          # Apply overlays
          overlays = import ./.idx/overlays/default.nix;
          extendedPkgs = builtins.foldl' (p: overlay: p.extend overlay) pkgs overlays;

          # Base packages
          basePackages = import ./.idx/modules/packages.nix {
            pkgs = extendedPkgs;
            inherit lib;
          };

          # Slint Android module (for manual shell)
          slintAndroid = import ./.idx/modules/slint-android {
            pkgs = extendedPkgs;
            inherit lib system;
          };

          slintPackages = import ./.idx/modules/packages.nix {
            pkgs = extendedPkgs;
            inherit lib;
          };

          slintEnvironment = import ./.idx/modules/environment.nix {
            pkgs = extendedPkgs;
            inherit lib;
          };

        in {
          # Default shell: minimal with overlays
          default = pkgs.mkShell {
            name = "dev-environment";

            buildInputs = basePackages;

            shellHook = ''
              echo ""
              echo "╔═══════════════════════════════════════════════════╗"
              echo "║     📦 Base Development Environment               ║"
              echo "╚═══════════════════════════════════════════════════╝"
              echo ""
              echo "✅ Overlays loaded (Android SDK, Rust, Fenix)"
              echo ""
              echo "💡 To load Slint Android tools:"
              echo "   nix develop .#slint"
              echo ""
            '';
          };

          # Slint shell: full Slint Android development
          slint = pkgs.mkShell ({
            name = "slint-android-dev";
            
            buildInputs = slintPackages ++ slintAndroid.packages;
            
            shellHook = ''
              echo ""
              echo "╔═══════════════════════════════════════════════════╗"
              echo "║  🎨 Slint Android Development Environment        ║"
              echo "╚═══════════════════════════════════════════════════╝"
              echo ""
              ${slintAndroid.shellHook}
            '';
            
          } // slintEnvironment // slintAndroid.env);
        }
      );

      # Apps
      apps = forAllSystems (system:
        let
          pkgs = nixpkgsFor system;
          lib = pkgs.lib;
          overlays = import ./.idx/overlays/default.nix;
          extendedPkgs = builtins.foldl' (p: overlay: p.extend overlay) pkgs overlays;

          slintAndroid = import ./.idx/modules/slint-android {
            pkgs = extendedPkgs;
            inherit lib system;
          };

          infoScript = lib.findFirst 
            (p: (p.name or "") == "slint-android-info") 
            null 
            slintAndroid.packages;

          buildScript = lib.findFirst
            (p: (p.name or "") == "slint-android-build")
            null
            slintAndroid.packages;

        in {
          info = {
            type = "app";
            program = "${infoScript}/bin/slint-android-info";
          };
          
          build = {
            type = "app";
            program = "${buildScript}/bin/slint-android-build";
          };
        }
      );

      # Formatter
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}