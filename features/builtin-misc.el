;; do not use package.el to download packages, we prefer nix
(setopt package-archives '())

;; do not ring the bell
(setopt ring-bell-function #'ignore)

(save-place-mode)

;; disable `indent-tabs-mode' by default
(setq-default indent-tabs-mode nil)

;; we can enable all disabled command
;; by setting `disabled-command-function' to nil
(dolist (command '(narrow-to-page
                   narrow-to-region))
  (put command 'disabled nil))

(setopt dired-copy-dereference t
        dired-listing-switches "-abFhl"
        dired-ls-F-marks-symlinks (eq system-type 'darwin))

(setopt kill-ring-max 200)

(setopt search-ring-max 100
        regexp-search-ring-max 100)

(setopt recentf-max-saved-items 60)
(recentf-mode)

(defconst wonima-emacs-autosave-directory
  (expand-file-name "autosave/" wonima-emacs-data-directory)
  "A directory to store Emacs autosave files.
It is under `wonima-emacs-data-directory'")
(make-directory wonima-emacs-autosave-directory t)
(defconst wonima-emacs-backup-directory
  (expand-file-name "backup/" wonima-emacs-data-directory)
  "A directory to store Emacs backup files.
It is under `wonima-emacs-data-directory'")
(make-directory wonima-emacs-backup-directory t)

;; TODO improve security
;; Tramp can access privileged files via sudo or friends
;; we should carefully treat backup and auto-save files of privileged files
;; either store they near the original file (like lock files) or do not backup/auto-save
;; related:
;;   `backup-enable-predicate' `backup-inhibited'
;;   `auto-save-mode' `buffer-auto-save-file-name' `auto-save-interval' `auto-save-timeout'
(setopt auto-save-file-name-transforms `((".*" ,wonima-emacs-autosave-directory sha256)))
(setopt backup-directory-alist `(("." .  ,wonima-emacs-backup-directory)))

;; fail to auto check kitty's capabilities, at least for setSelection
;; so we hardcode some capabilities we care
(setopt xterm-extra-capabilities '(setSelection))

(winner-mode)

(defun wonima-other-window-reverse (count &optional all-frames interactive)
  "Like `other-window', but uses the reverse order."
  (interactive "p\ni\np")
  (funcall-interactively #'other-window (- count) all-frames interactive))
(keymap-global-set "C-x O" #'wonima-other-window-reverse)

(setopt auto-revert-remote-files t)

(setopt tramp-default-method "rsync")
(with-eval-after-load 'tramp
  ;; each user has different PATH on NixOS
  (defvar tramp-remote-path)
  (cl-pushnew 'tramp-own-remote-path
              tramp-remote-path))
