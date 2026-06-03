(setopt consult-async-min-input 2)
;; mainly to show available narrow keys by pressing `consult-narrow-key' followed by C-h
(setopt consult-narrow-key "C-+")
(with-eval-after-load 'consult
  (add-hook 'consult-preview-allowed-hooks #'global-hl-todo-mode))
(advice-add #'register-preview :override #'consult-register-window)
(setopt xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

;; `C-x' prefix key
(keymap-global-set "<remap> <switch-to-buffer>" #'consult-buffer)
(keymap-global-set "<remap> <switch-to-buffer-other-window>" #'consult-buffer-other-window)
(keymap-global-set "<remap> <switch-to-buffer-other-tab>" #'consult-buffer-other-tab)
(keymap-global-set "<remap> <switch-to-buffer-other-frame>" #'consult-buffer-other-frame)
(keymap-global-set "<remap> <project-switch-to-buffer>" #'consult-project-buffer)
(keymap-global-set "<remap> <repeat-complex-command>" #'consult-complex-command)
(keymap-global-set "<remap> <bookmark-jump>" #'consult-bookmark)

;; `M-g' prefix key / `goto-map'
(keymap-global-set "<remap> <goto-line>" #'consult-goto-line)
(keymap-global-set "M-g e" #'consult-compile-error)
(keymap-global-set "M-g f" #'consult-flymake)
(keymap-global-set "M-g o" #'consult-outline)
(keymap-global-set "M-g O" #'consult-org-heading)
(keymap-global-set "<remap> <imenu>" #'consult-imenu)
(keymap-global-set "M-g I" #'consult-imenu-multi)
(keymap-global-set "M-g r" #'consult-grep-match)
;; consult-mark, consult-global-mark

;; `M-s' prefix key / `search-map'
(keymap-global-set "M-s d" #'consult-fd)
(keymap-global-set "M-s D" #'consult-find)
(keymap-global-set "M-s r" #'consult-ripgrep)
(keymap-global-set "M-s g" #'consult-grep)
(keymap-global-set "M-s G" #'consult-git-grep)
(keymap-global-set "M-s l" #'consult-line)
(keymap-global-set "M-s L" #'consult-line-multi)
(keymap-global-set "M-s k" #'consult-keep-lines)
(keymap-global-set "M-s u" #'consult-focus-lines)
(keymap-global-set "M-s i" #'consult-info)
(keymap-set Info-mode-map "<remap> <Info-search>" #'consult-info)
(keymap-global-set "M-s e" #'consult-isearch-history)
(keymap-set isearch-mode-map "<remap> <isearch-edit-string>" #'consult-isearch-history)
;; bind these in `isearch-mode-map'
;; so that the current search string can be used as the default/initial value
(keymap-set isearch-mode-map "M-s l" #'consult-line)
(keymap-set isearch-mode-map "M-s L" #'consult-line-multi)

(keymap-global-set "<remap> <yank-pop>" #'consult-yank-pop)

;; (keymap-global-set "C-c M-x" #'consult-mode-command)
;; (keymap-global-set "C-c m" #'consult-man)
;; (keymap-global-set "C-c k" #'consult-kmacro)

;; consult-register, consult-register-load, consult-register-store

(defvar wonima-consult-shell-or-terminal-buffer-modes
  '(vterm-mode eshell-mode)
  "A list of major mode symbols.
Buffers of any of these major modes are considered as shell or terminal buffers.")
;; we modify plist manually without using `plist-put' to keep the old list unchanged
(defun wonima--consult-get-shell-or-terminal-buffers (&optional within-current-project-flag)
  "Return a list of info for shell or terminal buffers.

When WITHIN-CURRENT-PROJECT-FLAG is non-nil,
returned buffers are within the current project.
If there is no current project, return an empty list.

When WITHIN-CURRENT-PROJECT-FLAG is nil, all buffers are considered."
  (declare-function consult--buffer-pair "consult")
  (let ((args (list :mode wonima-consult-shell-or-terminal-buffer-modes
                    :as #'consult--buffer-pair)))
    (declare-function consult--project-root "consult")
    (declare-function consult--buffer-query "consult")
    (if within-current-project-flag
        (when-let* ((project-root (consult--project-root)))
          (apply #'consult--buffer-query (append args (list :directory project-root))))
      (apply #'consult--buffer-query args))))
(declare-function consult--buffer-state "consult")
(defconst wonima--consult-source-shell-or-terminal-buffer
  (list :name "Shell or Terminal"
        :narrow ?s
        :hidden t
        :category 'buffer
        :face 'consult-buffer
        :history 'buffer-name-history
        :state #'consult--buffer-state
        :items #'wonima--consult-get-shell-or-terminal-buffers)
  "Shell or terminal buffer source.")
(defconst wonima--consult-source-project-shell-or-terminal-buffer
  (append
   (list :enabled (lambda () (defvar consult-project-function) consult-project-function)
         :items (lambda () (wonima--consult-get-shell-or-terminal-buffers t)))
   wonima--consult-source-shell-or-terminal-buffer)
  "Project shell or terminal buffer source.")
(defconst wonima--consult-source-project-shell-or-terminal-buffer-2
  (append '(:narrow ?S) wonima--consult-source-project-shell-or-terminal-buffer)
  "Like `wonima--consult-source-project-shell-or-terminal-buffer',
but use a different narrow key.")
(with-eval-after-load 'consult
  (defvar consult-buffer-sources)
  (dolist (source '(wonima--consult-source-shell-or-terminal-buffer
                    wonima--consult-source-project-shell-or-terminal-buffer-2))
    (cl-pushnew source consult-buffer-sources))
  (defvar consult-project-buffer-sources)
  (cl-pushnew 'wonima--consult-source-project-shell-or-terminal-buffer
              consult-project-buffer-sources))
