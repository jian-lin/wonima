{ thisFeature }:

{ lib, config, ... }:

{
  # this env var needs to be given to the main Emacs instance via shell, NixOS or Home Manager
  options.main-instance-env-var = lib.mkOption {
    type = lib.types.str;
    default = "WONIMA_MAIN_INSTANCE";
    description = ''
      When an Emacs instance finds this env var is set,
      that Emacs instance is the main instance.

      Some commands (MUA) or background jobs (`run-with-idle-timer`)
      are only run in the main Emacs instance.
    '';
  };

  config.features.${thisFeature} = {
    elisp = ''
      (defconst wonima-main-emacs-instance-flag
        ;; use `getenv-internal' to search env vars in `initial-environment'
        ;; so that evaluating `defconst' multiple times can still get the right value
        (getenv-internal "${config.main-instance-env-var}" initial-environment)
        "Non-nil means this is the main Emacs instance.

      Some commands (MUA) or background jobs (`run-with-idle-timer')
      are only run in the main Emacs instance.")

      ;; of course, child Emacs instances are not the main instance
      (setenv "${config.main-instance-env-var}" nil)
    '';
  };
}
