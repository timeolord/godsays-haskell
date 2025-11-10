{
  description = "Haskell Project Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          packages = [
            dos2unix
            (haskellPackages.ghcWithPackages (
              pkgs: with pkgs; [
                cabal-install
              ]
            ))
          ];
        };
      }
    );
}
