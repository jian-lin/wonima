{
  self,
  inputs,
  lib,
  ...
}:

{
  flake.overlays.default = lib.composeExtensions inputs.nima.overlays.default (
    final: _prev: {
      mkWonima =
        emacs:
        final.mkNima {
          module = final.lib.modules.importApply ./nima.nix emacs;
          featuresDir = ./features;
        };
    }
  );

  perSystem =
    {
      pkgs,
      system,
      lib,
      ...
    }:
    {
      packages = lib.mapAttrs (_name: pkgs.mkWonima) {
        default = pkgs.emacs-pgtk;
        inherit (pkgs)
          emacs
          emacs-nox
          emacs-pgtk
          ;
      };

      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ self.overlays.default ];
        config = { };
      };
    };
}
