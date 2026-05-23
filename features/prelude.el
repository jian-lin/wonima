(defconst wonima-profile-flag nil
  "Whether to profile user configuration `load'ing.")
(when wonima-profile-flag (profiler-start 'cpu)) ;; `profiler-stop' in postlude

(defconst wonima-initial-gcs-done gcs-done
  "Number of GC done before `load'ing user configuration.")
(defconst wonima-initial-gc-elapsed gc-elapsed
  "Time used by GC before `load'ing user configuration.")

(require 'xdg)
(require 'cl-lib)

;; TODO move more stuff into these dirs
;; spec: https://specifications.freedesktop.org/basedir/latest/
(defconst wonima-emacs-state-directory (expand-file-name "emacs/" (xdg-state-home))
  "A directory to store Emacs state such as logs, history and recently used files.")
(defconst wonima-emacs-data-directory (expand-file-name "emacs/" (xdg-data-home))
  "A directory to store Emacs data.")
(dolist (dir (list wonima-emacs-state-directory
                   wonima-emacs-data-directory))
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
