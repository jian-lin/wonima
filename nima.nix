emacs:

{ lib, ... }:

{
  package = emacs;
  pedantic = true;

  overlay =
    final: prev:
    let
      wonimaPackages = {
        kitty-keyboard-protocol = mkEpkg { pname = "kitty-keyboard-protocol"; };
      };
      mkEpkg =
        {
          pname,
          packageRequires ? [ ],
        }:
        final.melpaBuild {
          inherit pname packageRequires;
          version = "0.1.0"; # a dummy version
          src = lib.path.append ./packages "${pname}.el";
        };
    in
    wonimaPackages // { inherit wonimaPackages; };
}
