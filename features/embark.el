(keymap-global-set "C-." #'embark-act)
(keymap-global-set "M-." #'embark-dwim)
(keymap-global-set "<remap> <describe-bindings>" #'embark-bindings)

(setq prefix-help-command #'embark-prefix-help-command)
