{ pkgs, lib, ... }:

{
  epkgs = epkgs: [
    epkgs.project-store
    epkgs.envrc
  ];

  overlay =
    final: prev:
    let
      project-store = "project-store";
    in
    {
      # Add project-store here instead of putting it in the packages/ dir
      # so that we can check if it is included in Nixpkgs.
      ${project-store} =
        lib.throwIf (lib.hasAttr project-store prev)
          "Remove locally added ${project-store} since it is already in Nixpkgs"
          final.elpaBuild
          (finalAttrs: {
            pname = project-store;
            version = "0.9.0";
            src = pkgs.fetchurl {
              url = "https://elpa.nongnu.org/nongnu/project-store-${finalAttrs.version}.tar";
              hash = "sha256-SjjLJf6o3GhzHCR7IQkh4PDBe815ZHZ+ABA1RRJ1fUQ=";
            };
          });
    };
}
