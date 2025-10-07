{
  description = "Slint Android Development Environment";

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

          # Import Slint Android module
          slintAndroid = import ./.idx/modules/slint-android {
            inherit pkgs lib system;
          };

          # Import packages
          packages = import ./.idx/modules/packages.nix {
            inherit pkgs lib slintAndroid;
          };

          # Import environment
          environment = import ./.idx/modules/environment.nix {
            inherit lib slintAndroid;
          };

        in {
          default = pkgs.mkShell ({
            name = "slint-android-dev";
            
            buildInputs = packages;
            
            shellHook = ''
              echo ""
              echo "╔═══════════════════════════════════════════════════╗"
              echo "║  🎨 Slint Android Development Environment        ║"
              echo "╚═══════════════════════════════════════════════════╝"
              echo ""
              ${slintAndroid.shellHook}
            '';
            
          } // environment);
        }
      );

      # Packages
      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor system;
          lib = pkgs.lib;

          slintAndroid = import ./.idx/modules/slint-android {
            inherit pkgs lib system;
          };

        in {
          default = slintAndroid.emulator;
          slint-android-emulator = slintAndroid.emulator;
        }
      );

      # Apps
      apps = forAllSystems (system:
        let
          pkgs = nixpkgsFor system;
          lib = pkgs.lib;

          slintAndroid = import ./.idx/modules/slint-android {
            inherit pkgs lib system;
          };

          infoScript = lib.findFirst 
            (p: (p.name or "") == "slint-android-info") 
            null 
            slintAndroid.packages;

        in {
          default = {
            type = "app";
            program = "${slintAndroid.emulator}/bin/run-test-*";
          };
          
          info = {
            type = "app";
            program = "${infoScript}/bin/slint-android-info";
          };
        }
      );

      # Formatter
      formatter = forAllSystems (system:
        nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}