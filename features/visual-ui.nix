{
  epkgs = epkgs: builtins.attrValues {
    inherit (epkgs)
      modus-themes
      breadcrumb
      paren-face
      hl-todo
      ;
  };
}
