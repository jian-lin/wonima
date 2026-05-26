{
  epkgs =
    epkgs:
    builtins.attrValues {
      inherit (epkgs)
        modus-themes
        paren-face
        hl-todo
        ;
    }
    ++ [
      epkgs.elpaDevelPackages.breadcrumb # for not-yet-released performance improvements
    ];
}
