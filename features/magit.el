(with-eval-after-load 'project
  (defvar project-switch-commands)
  (keymap-set project-prefix-map "m" #'magit-project-status)
  (setf (alist-get #'magit-project-status project-switch-commands) '("Magit")))

(setopt magit-diff-refine-hunk 'all)

(defun wonima--magit-insert-tags-header-fast ()
  "A fast version of `magit-insert-tags-header'.

Normally, it is the same as `magit-insert-tags-header'.
But in some repos, this is a no-op.

When it is a no-op, it is usually because it takes some time to run
`magit-insert-tags-header', and the result is not very useful."
  (declare-function magit-toplevel "magit-git")
  (declare-function project-name "project")
  (unless (member (project-name (project-current nil (magit-toplevel)))
                  '("nixpkgs"))
    (magit-insert-tags-header)))
(with-eval-after-load 'magit-status
  (declare-function magit-insert-tags-header "magit-status")
  (remove-hook 'magit-status-headers-hook #'magit-insert-tags-header)
  (add-hook 'magit-status-headers-hook #'wonima--magit-insert-tags-header-fast 90))

;; TODO to only notify after 5 or 10 seconds, we may try to advice some magit function
(defun wonima--notify-when-magit-clone-finish ()
  "Notify when `magit-clone' finishes."
  (require 'notifications)
  (declare-function notifications-get-server-information "notifications")
  (declare-function notifications-notify "notifications")
  ;; first, check if a notification server is available
  (when (notifications-get-server-information)
    (notifications-notify :title "magit-clone finishes"
                          :body default-directory
                          :app-name "magit.el")))
(add-hook 'magit-post-clone-hook #'wonima--notify-when-magit-clone-finish)
;; TODO also notify when pull/fetch finishes
;; magit author prefers doing so using a git hook (magit#4849), is it possible?
