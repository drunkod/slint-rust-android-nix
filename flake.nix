{
  description = "Slint Android Development Environment (Minimal)";

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
              echo "║           (Minimal - No Emulator)                ║"
              echo "╚═══════════════════════════════════════════════════╝"
              echo ""
              ${slintAndroid.shellHook}
            '';
            
          } // environment);
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