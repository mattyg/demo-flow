{
  description = "Flake for development workflows.";

  inputs = {
    rainix.url = "github:rainprotocol/rainix/c0ec270110349723cc26dbceb8f56d5c8d5ce8b7";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {self, flake-utils, rainix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = rainix.pkgs.${system};
      in rec {
        packages =  rainix.packages.${system};

        devShells.default = rainix.devShells.${system}.default;
      }
    );

}
