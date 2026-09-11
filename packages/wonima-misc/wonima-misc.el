;;; wonima-misc.el --- Misc functions  -*- lexical-binding: t; -*-

;; SPDX-FileCopyrightText: 2023 Lin Jian <me@linj.tech>
;; SPDX-License-Identifier: GPL-3.0-or-later

;; Author: Lin Jian <me@linj.tech>
;; Version: 0.1.0
;; Keywords: convenience

;;; Commentary:

;;; Code:

;; TODO move more content here from the old file

(require 'cl-lib)

(defun wonima-misc-delta-time-to-string (start-time end-time)
  "Format delta of END-TIME and START-TIME as a human-readable string."
  (format-seconds "%Y %D %H %M %z%S"
                  (time-convert (time-subtract end-time start-time) 'integer)))

(defun wonima-misc-cl-prettyexpand (form)
  "Like `cl-prettyexpand', but usually genrate a more readable expansion.

Call `cl-prettyexpand' with FORM
with `print-gensym' and `print-circle' bound to t."
  (let ((print-gensym t)
        (print-circle t))
    (cl-prettyexpand form)))

(provide 'wonima-misc)

;;; wonima-misc.el ends here
