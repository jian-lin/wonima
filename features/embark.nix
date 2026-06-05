{ lib, config, ... }:

{
  epkgs =
    epkgs:
    [
      epkgs.embark
    ]
    ++ lib.optional config.features.consult.enable epkgs.embark-consult;
}
