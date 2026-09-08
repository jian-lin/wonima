{ lib, ... }:

{
  epkgs = epkgs: [ epkgs.eglot ];

  overlay = final: prev: {
    # Use Emacs 31 builtin xref because currently it is newer than the GNU ELPA one.
    xref =
      lib.throwIfNot (lib.versionAtLeast "1.7.0" prev.xref.version)
        "Remove xref overlay: get it from ELPA since it is newer than the Emacs31 builtin one"
        null;
  };
}
