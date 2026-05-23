# SPDX-FileCopyrightText: 2026 Lin Jian <me@linj.tech>
# SPDX-License-Identifier: GPL-3.0-or-later

{
  description = "The public part of my Emacs configuration configured with nima";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nima = {
      url = "github:jian-lin/nima";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        # git-hooks-nix.follows = "";
        # nix-unit.follows = "";
        # treefmt-nix.follows = "";
      };
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { lib, ... }:
      {
        imports = [
          ./module.nix
          ./ci.nix
        ];

        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
      }
    );
}
