{
  description = "Flake for development workflows.";

  inputs = {
    rainix.url = "github:rainprotocol/rainix";
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    rain.url = "github:rainprotocol/rain.cli/6a912680be6d967fd6114aafab793ebe8503d27b";
  };

  outputs = { self, nixpkgs, rain, flake-utils, rainix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rain-cli = "${rain.defaultPackage.${system}}/bin/rain";
        build-meta-cmd = ''
          ${rain-cli} meta build \
            -i <(${rain-cli} meta solc artifact -c abi -i out/Flow.sol/Flow.json) -m solidity-abi-v2 -t json -e deflate -l en \
            -i lib/rain.flow/src/concrete/basic/Flow.meta.json -m interpreter-caller-meta-v1 -t json -e deflate -l en \
        '';
      in rec {
        packages = rec {
          build-single-meta =  ''
            ${(build-meta-cmd)} -o meta/Flow.rain.meta;
          '';
          build-meta = pkgs.writeShellScriptBin "build-meta" (''
            forge build --force;
            '' + build-single-meta);

          default = build-meta;
        };
      }
    );

}
