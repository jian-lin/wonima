;; TODO Should we customize completion style of eglot?
;; The author of eglot says we shouldn't because some completion styles change sort order.
;; But orderless does not sort, so it is fine?
;; related: `completion-category-overrides'

;; Show only the first line of doc, usually being the function signature
;; to avoid resizing minibuffer due to showing a larger part of doc.
;; The whole doc can still be viewed by `eldoc-doc-buffer' when needed.
;; https://github.com/joaotavora/eglot/discussions/734
(setopt eldoc-echo-area-use-multiline-p nil)

(setopt eglot-events-buffer-config '(:size 100000 :format lisp))

(with-eval-after-load 'eglot
  (defvar eglot-mode-map)
  (declare-function eglot-rename "eglot")
  (declare-function eglot-code-actions "eglot")
  (declare-function eglot-find-typeDefinition "eglot")
  (declare-function eglot-find-implementation "eglot")
  (declare-function eglot-find-declaration "eglot")
  (keymap-set eglot-mode-map "C-c l r" #'eglot-rename)
  (keymap-set eglot-mode-map "C-c l a" #'eglot-code-actions)
  (keymap-set eglot-mode-map "C-c l t" #'eglot-find-typeDefinition)
  (keymap-set eglot-mode-map "C-c l i" #'eglot-find-implementation)
  (keymap-set eglot-mode-map "C-c l d" #'eglot-find-declaration))

(defun wonima-display-buffer-file-name ()
  "Display variable `buffer-file-name' when non-nil.
If in a project, display in a project-friendly form."
  (when buffer-file-name
    (message "At %s"
             (if-let* ((project (project-current)))
                 (format "%s %s"
                         (project-name project)
                         (file-relative-name buffer-file-name
                                             (project-root project)))
               buffer-file-name))))
(with-eval-after-load 'xref
  (dolist (hook '(xref-after-jump-hook xref-after-return-hook))
    (add-hook hook #'wonima-display-buffer-file-name)))
