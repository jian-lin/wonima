(defconst wonima-main-emacs-instance-flag
  ;; use `getenv-internal' to search env vars in `initial-environment'
  ;; so that evaluating `defconst' multiple times can still get the right value
  (getenv-internal "INVOCATION_ID" initial-environment)
  "Non-nil means this is the main Emacs instance.
Some things, such as `mu4e', are only run in the main Emacs instance.
This flag is heuristical.")

;; child Emacs instances will not be the main instance
(setenv "INVOCATION_ID" nil)
