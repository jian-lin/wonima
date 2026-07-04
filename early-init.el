;; increase gc threshold mainly to reduce gc during startup for a fast startup
;; maybe it also improve runtime performance
;; more info: 18:38 https://emacsconf.org/2023/talks/gc
;; use `setq' because `setopt' is unnecessary here, slower and triggers a few GC
(setq gc-cons-threshold (* 15 1000 1000))

(require 'xdg)

(defconst wonima-emacs-cache-directory (expand-file-name "emacs/" (xdg-cache-home))
  "A directory to store Emacs cache.")
(make-directory wonima-emacs-cache-directory t)

(startup-redirect-eln-cache (expand-file-name "eln-cache" wonima-emacs-cache-directory))
