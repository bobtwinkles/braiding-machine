{
  description = "design environment for braiding machine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils}:
    flake-utils.lib.eachDefaultSystem (system: {
      devShell = let
        pkgs = import nixpkgs {
          inherit system;
        };
        pythonPackage = pkgs.python310.withPackages (pythonPackages: with pythonPackages; [
          sympy
          numpy
        ]);
      in pkgs.mkShell {
        name = "braid-dev-shell";
        buildInputs = with pkgs; [
          pythonPackage
          gnuplot
          solvespace
        ];
      };
    });
}
