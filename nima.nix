emacs:

{ lib, config, ... }:

{
  package = emacs;
  pedantic = true;

  overlay =
    final: prev:
    let
      wonimaPackages = {
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
          turnCompilationWarningToError = config.pedantic;
        };
    in
    wonimaPackages // { inherit wonimaPackages; };
}
