{ thisFeature }:

{ lib, config, ... }:

{
  options.main-instance-flag = lib.mkOption {
    type = lib.types.str;
    default = "wonima-main-emacs-instance-flag";
    description = ''
      The main Emacs instance should set this variable when launched.

      Some commands (MUA) or background jobs (`run-with-idle-timer`)
      are only run in the main Emacs instance.
    '';
    readOnly = true;
  };

  config.features.${thisFeature} = {
    elisp = ''
      (defconst ${config.main-instance-flag} nil
        "Non-nil means this is the main Emacs instance.
      This variable should be set when the main Emacs instance is launched.

      Some commands (MUA) or background jobs (`run-with-idle-timer')
      are only run in the main Emacs instance.")
    '';
  };
}
