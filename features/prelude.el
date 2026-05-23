(defconst wonima-profile-flag nil
  "Whether to profile user configuration `load'ing.")
(when wonima-profile-flag (profiler-start 'cpu)) ;; `profiler-stop' in postlude

(defconst wonima-initial-gcs-done gcs-done
  "Number of GC done before `load'ing user configuration.")
(defconst wonima-initial-gc-elapsed gc-elapsed
  "Time used by GC before `load'ing user configuration.")

;; mainly to avoid gc during startup for a fast startup
;; ideally, this should be set in early-init.el to reduce more GC
;; more info: 18:38 https://emacsconf.org/2023/talks/gc
;; use `setq' because `setopt' is unnecessary here, slower and triggers a few GC
(setq gc-cons-threshold (* 15 1000 1000))

(require 'xdg)
(require 'cl-lib)

;; TODO move more stuff into these dirs
;; spec: https://specifications.freedesktop.org/basedir/latest/
(defconst wonima-emacs-state-directory (expand-file-name "emacs/" (xdg-state-home))
  "A directory to store Emacs state such as logs, history and recently used files.")
(defconst wonima-emacs-data-directory (expand-file-name "emacs/" (xdg-data-home))
  "A directory to store Emacs data.")
(defconst wonima-emacs-cache-directory (expand-file-name "emacs/" (xdg-cache-home))
  "A directory to store Emacs cache.")
(dolist (dir (list wonima-emacs-state-directory
                   wonima-emacs-data-directory
                   wonima-emacs-cache-directory))
  (make-directory dir t))

(defun wonima-hide-minor-mode-lighter (minor-mode file)
  "Hide the lighter of MINOR-MODE from feature or file FILE.
MINOR-MODE and FILE (when it is a feature) should be symbol."
  (with-eval-after-load file
    (let ((lighter (alist-get minor-mode minor-mode-alist)))
      (if lighter
          (setcar lighter nil)
        (message "Failed to hide lighter of `%s' because it is not in `minor-mode-alist'"
                 minor-mode)))))
