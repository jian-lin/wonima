(when (member (system-name) '("dazzle" "bane" "phoenix" "wisp"))
  (setopt kitty-keyboard-protocol-query-terminal-timeout 1))

(add-hook 'tty-setup-hook #'kitty-keyboard-protocol-enable)

;; called when emacsclient frame is deleted, not called when Emacs is killed
(add-hook 'delete-frame-functions #'kitty-keyboard-protocol-disable)

;; called when Emacs is killed
(add-hook 'kill-emacs-hook #'kitty-keyboard-protocol-disable)
