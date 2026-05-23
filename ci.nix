# the idea is stolen from https://github.com/nix-community/nix-github-actions

{ lib, self, ... }:

{
  flake.ci = {
    runners = {
      "x86_64-linux" = "ubuntu-latest";
      "aarch64-linux" = "ubuntu-24.04-arm";
      "aarch64-darwin" = "macos-latest";
    };
    checks =
      let
        filterOutDuplicatedDefault =
          _system: packages:
          let
            packagesWithoutDefault = lib.removeAttrs packages [ "default" ];
          in
          if lib.elem packages.default or null (lib.attrValues packagesWithoutDefault) then
            packagesWithoutDefault
          else
            packages;
      in
      lib.intersectAttrs self.ci.runners (lib.mapAttrs filterOutDuplicatedDefault self.packages);
    # CI workflow consumes this as things to build
    matrix = {
      include =
        let
          mkItems =
            system: checks:
            map (name: {
              inherit name system;
              attrPath = "ci.checks.${system}.${name}";
              runner = self.ci.runners.${system};
            }) (lib.attrNames checks);
        in
        self.ci.checks
        |> lib.mapAttrs mkItems
        |> lib.attrValues
        |> lib.concatLists;
    };
  };
}
