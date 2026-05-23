{ thisFeature }:

{ options, ... }:

{
  order = options.features.valueMeta.attrs.${thisFeature}.configuration.options.order.default - 10000;
}
