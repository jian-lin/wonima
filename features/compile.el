(setopt compilation-scroll-output 'first-error)

(add-hook 'compilation-mode-hook #'hl-line-mode)

(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(with-eval-after-load 'compile
  (defvar compilation-error-regexp-alist-alist)
  (dolist (item `((wonima-nix-build-elisp
                   ;; Regex matching a lot of text is not reliable.
                   ;; The elisp file can be far away so we don't try to match it here.
                   ,(rx line-start
                        (group (one-or-more (any alnum "-"))) ; name
                        "> "
                        (group "Error:"))
                   nil nil nil 2 nil (1 compilation-error-face) (2 compilation-error-face))
                  (wonima-nix-fod-hash-mismatch
                   ,(rx line-start
                        (seq "error: hash mismatch in fixed-output derivation"
                             (+? not-newline)
                             (group "/" (one-or-more not-newline) ".drv") ; file
                             (one-or-more not-newline)
                             "\n")
                        (seq (one-or-more blank)
                             "specified:"
                             (one-or-more blank)
                             (group "sha256-" (+? not-newline) "=")       ; specified hash
                             "\n")
                        (seq (one-or-more blank)
                             "got:"
                             (one-or-more blank)
                             (group "sha256-" (+? not-newline) "="))      ; got hash
                        line-end)
                   1 nil nil 2 3 (2 compilation-error-face) (3 compilation-info-face))))
    (cl-pushnew item compilation-error-regexp-alist-alist :test #'equal))
  (defvar compilation-error-regexp-alist)
  (dolist (item '(wonima-nix-build-elisp
                  wonima-nix-fod-hash-mismatch))
    (cl-pushnew item compilation-error-regexp-alist)))

(defvar wonima-compilation-notification-threshold 5
  "Send a notification if a compilation takes more seconds than this.

See also `wonima--notify-compilation-finish'.")
(require 'wonima-misc)
(defun wonima--notify-compilation-finish (compilation-buffer compilation-finish-state)
  "Notify when a compilation finishes.
Do not notify if compilation does not take more than
`wonima-compilation-notification-threshold' seconds."
  (defvar compilation--start-time)
  (defvar compilation-arguments)
  (let ((compilation-stop-time (float-time))
        (compilation-start-time (buffer-local-value 'compilation--start-time
                                                    compilation-buffer))
        ;; Not use `compile-command' because
        ;;   - it is not a buffer-local variable
        ;;   - it is not updated in `recompile' with a changed command
        (last-compile-command (car (buffer-local-value 'compilation-arguments
                                                       compilation-buffer))))
    (when (>= (- compilation-stop-time compilation-start-time)
              wonima-compilation-notification-threshold)
      ;; Avoid top-level `require' to speed up Emacs startup.
      ;; Use `eval-and-compile' to fix compile warning about unknown function.
      (eval-and-compile (require 'notifications))
      ;; TODO support kitty notification for (remote) terminal
      (notifications-notify
       :title (format "Compilation in Emacs@%s %s" (system-name) compilation-finish-state)
       :body (format "%s | %s | %s"
                     (wonima-misc-delta-time-to-string compilation-start-time
                                                       compilation-stop-time)
                     last-compile-command
                     (buffer-name compilation-buffer))
       :app-name "compile.el"))))
(add-hook 'compilation-finish-functions #'wonima--notify-compilation-finish)
