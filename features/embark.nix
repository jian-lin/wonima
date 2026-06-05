{
  epkgs = epkgs: builtins.attrValues {
    inherit (epkgs)
      embark
      embark-consult
      wgrep
      ;
  };
}
