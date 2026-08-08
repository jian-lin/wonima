{ pkgs, ... }:

{
  epkgs = epkgs: [
    epkgs.project-nix-store
    epkgs.envrc
  ];

  overlay = final: prev: {
    envrc = prev.envrc.overrideAttrs (old: {
      patches = old.patches or [ ] ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/purcell/envrc/commit/e8c13917d65fae3adabb272648c56ecb9b026680.patch";
          hash = "sha256-5IjLlQfH6tUpCs6vOgDNbd9FVSjU2AWlA6wYtSIogHQ=";
        })
      ];
    });
  };
}
