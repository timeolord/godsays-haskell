{
  pkgs ?
  import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/33c6dca0c0cb31d6addcd34e90a63ad61826b28c.tar.gz";
  }) {}
}:
pkgs.mkShell {
  allowUnfree = true;
  packages = with pkgs; [
    dos2unix
    (haskellPackages.ghcWithPackages (pkgs: with pkgs; [
      cabal-install
    ]))
  ];
}
