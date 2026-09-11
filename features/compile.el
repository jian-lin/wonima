(setopt compilation-scroll-output 'first-error)

(add-hook 'compilation-mode-hook #'hl-line-mode)

(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(with-eval-after-load 'compile
  (defvar compilation-error-regexp-alist-alist)
  (dolist (item `((wonima-nix-build-elisp
                   ,(rx line-start
                        (one-or-more (any alnum "-"))                ; pname
                        "> Error:"
                        (+? not-newline)
                        (group "/" (one-or-more not-newline) ".el")) ; file
                   1 nil nil 2 1)
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
                             (group "sha256-" (one-or-more alnum) "=")    ; specified hash
                             "\n")
                        (seq (one-or-more blank)
                             "got:"
                             (one-or-more blank)
                             (group "sha256-" (one-or-more alnum) "="))   ; got hash
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
  (let ((compilation-stop-time (float-time))
        (compilation-start-time (buffer-local-value 'compilation--start-time
                                                    compilation-buffer)))
    (when (>= (- compilation-stop-time compilation-start-time)
              wonima-compilation-notification-threshold)
      (defvar compilation-arguments)
      ;; Avoid top-level `require' to speed up Emacs startup.
      ;; Use `eval-and-compile' to fix compile warning about unknown function.
      (eval-and-compile (require 'notifications))
      ;; TODO support kitty notification for (remote) terminal
      (notifications-notify
       :title (format "Compilation in Emacs@%s %s" (system-name) compilation-finish-state)
       :body (format "%s | %s | %s"
                     (wonima-misc-delta-time-to-string compilation-start-time
                                                       compilation-stop-time)
                     ;; Buffer-local value of last compile command.
                     (car (buffer-local-value 'compilation-arguments
                                              compilation-buffer))
                     (buffer-name compilation-buffer))
       :app-name "compile.el"))))
(add-hook 'compilation-finish-functions #'wonima--notify-compilation-finish)
