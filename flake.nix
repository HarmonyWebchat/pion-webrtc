{
  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/26.05";

      flake-parts.url = "github:hercules-ci/flake-parts";
      flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

      flake-compat.url = "github:NixOS/flake-compat";
      flake-compat.flake = false;
    };

  outputs =
    { flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake
      { inherit inputs; }
      (
        { lib, config, ... }:
        {
          systems = lib.systems.flakeExposed;

          imports =
            [
              ./.nix/modules/flake-parts/persystem-containers.nix

              flake-parts.flakeModules.modules
            ];

          flake.modules.nixos.default = import ./.nix/modules/nixos/default.nix;
          flake.nixosModules = config.flake.modules.nixos;

          perSystem =
            { self', pkgs, ... }:
            {
              packages =
                {
                  default = self'.packages.pion-webrtc-sfu;

                  pion-webrtc-sfu =
                    pkgs.callPackage
                      ./.nix/packages/sfu-package.nix
                      {
                        inherit (self'.packages) medooze-webrtc-sdp;
                      };

                  medooze-webrtc-sdp = pkgs.callPackage ./.nix/packages/sdp-package.nix {};
                };

              containers.docker =
                {
                  default = self'.containers.docker.pion-webrtc;

                  pion-webrtc =
                    pkgs.dockerTools.buildLayeredImage
                      {
                        name = "spacebar-webrtc-pion";

                        tag =
                          builtins.replaceStrings
                            [ "+" ]
                            [ "_" ]
                            self'.packages.pion-webrtc-sfu.version;

                        contents =
                          with pkgs.dockerTools;
                          [
                            binSh
                            usrBinEnv
                            caCertificates

                            self'.packages.pion-webrtc-sfu
                          ];

                        # NOTE: Marked TODO in the original flake.
                        config =
                          {
                            WorkingDir = "/data";
                            Env = [ "PORT=3001" ];

                            Cmd = [ (lib.getExe self'.packages.pion-webrtc-sfu) ];

                            Expose = [ "3001" ];
                          };
                      };
                };

              devShells.default =
                pkgs.mkShellNoCC
                  {
                    packages = [ pkgs.go_1_26 ];
                  };

              checks =
                {
                  packages =
                    pkgs.runCommand
                      "pion-webrtc--test-packages"
                      {
                        inherit (self'.packages)
                          pion-webrtc-sfu
                          medooze-webrtc-sdp
                          ;
                      }
                      "touch $out";

                  containers =
                    pkgs.runCommand
                      "pion-webrtc--test-containers"
                      {}
                      /* bash */
                      ''
                        test -f "${self'.containers.docker.pion-webrtc}" && touch $out
                      '';
                };
            };
        }
      );
}
