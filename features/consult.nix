{ pkgs, ... }:

{
  epkgs = epkgs: [
    epkgs.consult
    pkgs.fd
    pkgs.ripgrep
  ];
}
