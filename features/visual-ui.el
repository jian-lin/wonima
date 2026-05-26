;; this is not autoloaded by emacs-nox
;; and there is already no scroll bar by default in emacs-nox
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

(column-number-mode)
(tool-bar-mode -1)
(menu-bar-mode -1)

(setopt modus-themes-italic-constructs t)
;; we pass t to NO-CONFIRM because we use the newer version of modus-theme
;; instead of the builtin one
(load-theme 'modus-operandi t)

(add-hook 'window-size-change-functions #'frame-hide-title-bar-when-maximized)

;; workaround for not getting focus on gnome
;; https://gitlab.gnome.org/GNOME/mutter/-/issues/881
(add-hook 'server-switch-hook #'raise-frame)

(setopt tab-bar-show 1
        tab-bar-tab-hints t
        tab-bar-select-tab-modifiers '(meta))
(tab-bar-mode)

(declare-function ediff-setup-windows-plain "ediff-wind")
(setopt ediff-split-window-function #'split-window-horizontally
        ediff-window-setup-function #'ediff-setup-windows-plain)

(setopt recenter-redisplay nil)

;; `breadcrumb-mode' autoloads breadcrumb.el which requires pulse.el.
;; Derfer loading pulse.el by deferring loading breadcrumb.el to work around Emacs bug#81829:
;;   `pulse-flag' has wrong value in Emacs daemon if pulse.el is loaded too early.
(defvar wonima--is-breadcrumb-mode-once-enabled nil)
(defun wonima--enable-breadcrumb-mode-once ()
  (unless wonima--is-breadcrumb-mode-once-enabled
    (breadcrumb-mode)
    (setq wonima--is-breadcrumb-mode-once-enabled t)))
(if (daemonp)
    (add-hook 'server-after-make-frame-hook #'wonima--enable-breadcrumb-mode-once)
  (wonima--enable-breadcrumb-mode-once))

(defun wonima-disable-project-mode-line-locally-when-breadcrumb-is-enabled ()
  "No need to show project name in mode line since breadcrumb covers this info."
  (defvar breadcrumb-local-mode)
  (if breadcrumb-local-mode
      (setq-local project-mode-line nil)
    (setq-local project-mode-line (default-value 'project-mode-line))))
(add-hook 'breadcrumb-local-mode-hook
          #'wonima-disable-project-mode-line-locally-when-breadcrumb-is-enabled)

;; not use `setopt' to not discard default values
(with-eval-after-load 'paren-face
  (defvar paren-face-modes)
  (cl-pushnew 'geiser-repl-mode paren-face-modes))
(declare-function global-paren-face-mode "paren-face")
(global-paren-face-mode)

(global-hl-todo-mode)
