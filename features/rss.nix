{ config, ... }:

{
  epkgs = epkgs: [ epkgs.elfeed ];
  order = config.features.main-instance.order + 1;
}
