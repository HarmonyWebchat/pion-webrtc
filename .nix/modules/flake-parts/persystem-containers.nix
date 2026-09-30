{ flake-parts-lib, lib, ... }:
flake-parts-lib.mkTransposedPerSystemModule
  {
    name = "containers";
    option =
      lib.mkOption
        {
          type =
            lib.types.lazyAttrsOf (lib.types.lazyAttrsOf lib.types.package);
          default = {};
          description = ''
            per-system containers, such as generic oci containers or docker containers.
          '';
        };
    file = ./persystem-containers.nix;
  }
