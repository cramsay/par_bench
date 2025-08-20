let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
  hPkgs = p: [
    p.threadscope
    p.parallel
    p.mustache
  ];
  pyPkgs = p: [
    p.pip
    p.numpy
    p.pandas
    p.plotly
    p.jupyterlab
    p.scipy
  ];
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    (haskellPackages.ghcWithPackages hPkgs)
    (python3.withPackages pyPkgs)
  ];
}
