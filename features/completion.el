;;;;; completion style

;; 'basic is needed by dynamic completion tables
(setopt completion-styles '(orderless basic))

;; prepend 'partial-completion since it is useful for completing file paths
;; in addition, it is needed for `find-file' to open multiple files at once using wildcards
(setopt completion-category-overrides '((file (styles partial-completion))))

(eval-when-compile
  (when (>= emacs-major-version 31)
    (error "Maybe we want to use Emacs 31 new option `completion-pcm-leading-wildcard'")))

;;;;; minibuffer completion

(setopt savehist-file (expand-file-name "history" wonima-emacs-data-directory))
(savehist-mode)
(setopt history-length 200
        history-delete-duplicates t)

;; filter out commands un-related to the current buffer for M-x
(setopt read-extended-command-predicate #'command-completion-default-include-p)

(setopt enable-recursive-minibuffers t)
(minibuffer-depth-indicate-mode)

;; keep cursor outside of the minibuffer prompt
(setopt minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))

(eval-when-compile
  (when (>= emacs-major-version 31)
    (error "Emacs 31 has builtin support for CRM indicator.  Use `crm-prompt' and remove our patch")))
(defun wonima--prepend-crm-indicator (args)
  "Prepend an indicator to the prompt of `completing-read-multiple'."
  (defvar crm-separator)
  (cons (format "[%s-separated list] %s"
                (string-replace "[ \t]*" "" crm-separator)
                (car args))
        (cdr args)))
(advice-add #'completing-read-multiple :filter-args #'wonima--prepend-crm-indicator)

(setopt vertico-cycle t)
(vertico-mode)

(marginalia-mode)

;;;;; in-buffer completion

(setopt tab-always-indent 'complete)

(global-completion-preview-mode)

(setopt corfu-preview-current nil)
;; NOTE missing candidates from language servers with or without orderless
;;   - language servers probably won't send all candidates at once
;;   - corfu won't update candidates from language servers after `corfu-insert-separator'
;; see also the corfu wiki section "Configuring Corfu for Eglot"
(with-eval-after-load 'corfu
  (defvar corfu-map)
  (declare-function corfu-insert-separator "corfu")
  ;; better orderless integration
  (keymap-set corfu-map "SPC" #'corfu-insert-separator))
(global-corfu-mode)
(corfu-popupinfo-mode)
(corfu-history-mode)

(eval-when-compile
  (when (>= emacs-major-version 31)
    (error "Remove 3rd-party `corfu-terminal-mode', not needed by Emacs 31")))
(add-hook 'tty-setup-hook #'corfu-terminal-mode)

(with-eval-after-load 'dabbrev
  (defvar dabbrev-ignored-buffer-modes)
  (dolist (mode '(authinfo-mode doc-view-mode))
    (cl-pushnew mode dabbrev-ignored-buffer-modes)))
;; swap keybindings to prefer completion
(keymap-global-set "M-/" #'dabbrev-completion)
(keymap-global-set "C-M-/" #'dabbrev-expand)

(keymap-global-set "C-c p" 'cape-prefix-map)
(add-hook 'completion-at-point-functions #'cape-file)
;; TODO maybe also bind `cape-history' for eshell and shell
(dolist (command '(previous-matching-history-element next-matching-history-element))
  (keymap-set minibuffer-mode-map
              (format "<remap> <%s>" (symbol-name command))
              #'cape-history))
