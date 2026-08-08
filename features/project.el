(setopt project-mode-line t
        project-list-file (expand-file-name "projects" wonima-emacs-state-directory)
        project-kill-buffers-display-buffer-list t)

(declare-function project-prefixed-buffer-name "project")
(setopt project-compilation-buffer-name-function #'project-prefixed-buffer-name)

(with-eval-after-load 'project
  (add-hook 'project-find-functions #'project-store-try -20)
  (add-hook 'project-list-exclude #'project-store-p))

(envrc-global-mode)
