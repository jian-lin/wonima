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

(pixel-scroll-precision-mode)

(declare-function ediff-setup-windows-plain "ediff-wind")
(setopt ediff-split-window-function #'split-window-horizontally
        ediff-window-setup-function #'ediff-setup-windows-plain)

(setopt recenter-redisplay nil)

(breadcrumb-mode)

;; not use `setopt' to not discard default values
(with-eval-after-load 'paren-face
  (defvar paren-face-modes)
  (cl-pushnew 'geiser-repl-mode paren-face-modes))
(declare-function global-paren-face-mode "paren-face")
(global-paren-face-mode)

(global-hl-todo-mode)
