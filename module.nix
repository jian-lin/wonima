# SPDX-FileCopyrightText: 2026 Lin Jian <me@linj.tech>
# SPDX-License-Identifier: GPL-3.0-or-later

{
  self,
  inputs,
  lib,
  ...
}:

{
  flake.overlays = {
    default = self.overlays.wonima;
    wonima = lib.composeExtensions inputs.nima.overlays.default (
      final: _prev: {
        mkWonima =
          emacs:
          final.mkNima {
            module = { config, ... }: {
              package = emacs;
              pedantic = true;
              overlay = import ./package-overlay.nix {
                inherit (final) lib;
                inherit (config) pedantic;
              };
            };
            featuresDir = ./features;
          };
      }
    );
    packages = final: prev: {
      emacsPackagesFor =
        emacs:
        (prev.emacsPackagesFor emacs).overrideScope (
          import ./package-overlay.nix {
            inherit (final) lib;
            pedantic = true;
          }
        );
    };
  };

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
        overlays = [ self.overlays.wonima ];
        config = { };
      };
    };
}
