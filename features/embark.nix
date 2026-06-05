{ lib, config, ... }:

{
  epkgs =
    epkgs:
    [
      epkgs.embark
      epkgs.wgrep
    ]
    ++ lib.optional config.features.consult.enable epkgs.embark-consult;
}
