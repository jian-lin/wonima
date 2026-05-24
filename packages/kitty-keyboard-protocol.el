;;; kitty-keyboard-protocol.el --- Implement kitty keyboard protocol  -*- lexical-binding: t; -*-

;; Copyright (C) 2023-2026 Lin Jian

;; Author: Lin Jian <me@linj.tech>
;; Version: 0.1.0
;; Keywords: terminals

;;; Commentary:

;; This package implements the kitty keyboard protocol listed on
;; https://sw.kovidgoyal.net/kitty/keyboard-protocol.

;; For now, only "disambiguate escape codes" (0b1) is implemented.

;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=58747

;; There is a similar package called kkp[1] from which I may learn
;; something.
;; [1]: https://github.com/benjaminor/kkp

;;; Code:

;; TODO use `cl-defstruct' for
;;   [X] modifier-code-and-modifiers
;;   [ ] key-table-item
;;   [ ] keymap-item
;; TODO make some vars private
;; TODO what is "Report alternate keys"? Is it worth implementing?

(require 'cl-lib)
(require 'generator)

(defgroup kitty-keyboard-protocol
  nil
  "Implement kitty keyboard protocol."
  :group 'terminals
  :prefix "kitty-keyboard-protocol-")

(cl-defstruct
    (kitty-keyboard-protocol--modifier-set
     (:constructor kitty-keyboard-protocol--modifier-set-make)
     (:copier nil))
  "A modifier set consists of modifier keys and its encoded value."
  (keys nil
        :read-only t
        :type list
        :documentation "The list of modifier key symbols.")
  (value nil
         :read-only t
         :type integer
         :documentation "The encoded value."))

(defconst kitty-keyboard-protocol-text-key-table
  (let ((text-keys '(?` ?- ?= ?\[ ?\] ?\\ ?\; ?' ?, ?. ?/ ? ))
	table)
    (cl-loop for key from ?a to ?z
	     do (push key text-keys))
    (cl-loop for key from ?0 to ?9
	     do (push key text-keys))
    (dolist (key text-keys table)
      (push (list key key 'u) table)))
  "A list whose item is in the form of (KEY-SYMBOL NUMBER SUFFIX).
Space key is also added to this table.  Refer to
https://sw.kovidgoyal.net/kitty/keyboard-protocol/#legacy-text-keys
for more information.")

(defconst kitty-keyboard-protocol-functional-key-table
  '((escape 27 u)
    (return 13 u)
    (tab 9 u)
    (backspace 127 u)
    (insert 2 ~)
    (delete 3 ~)
    (left 1 D)
    (right 1 C)
    (up 1 A)
    (down 1 B)
    (prior 5 ~)
    (next 6 ~)
    (home 1 H)
    (home 7 ~)
    (end 1 F)
    (end 8 ~)
    (Scroll_Lock 57359 u)
    (print 57361 u)
    (pause 57362 u)
    (f1 1 P)
    (f1 11 ~)
    (f2 1 Q)
    (f2 12 ~)
    (f3 1 R)
    (f3 13 ~)
    (f4 1 S)
    (f4 14 ~)
    (f5 15 ~)
    (f6 17 ~)
    (f7 18 ~)
    (f8 19 ~)
    (f9 20 ~)
    (f10 21 ~)
    (f11 23 ~)
    (f12 24 ~)
    (f13 57376 u)
    (f14 57377 u)
    (f15 57378 u)
    (f16 57379 u)
    (f17 57380 u)
    (f18 57381 u)
    (f19 57382 u)
    (f20 57383 u)
    (f21 57384 u)
    (f22 57385 u)
    (f23 57386 u)
    (f24 57387 u)
    (f25 57388 u)
    (f26 57389 u)
    (f27 57390 u)
    (f28 57391 u)
    (f29 57392 u)
    (f30 57393 u)
    (f31 57394 u)
    (f32 57395 u)
    (f33 57396 u)
    (f34 57397 u)
    (f35 57398 u)
    (kp-0 57399 u)
    (kp-1 57400 u)
    (kp-2 57401 u)
    (kp-3 57402 u)
    (kp-4 57403 u)
    (kp-5 57404 u)
    (kp-6 57405 u)
    (kp-7 57406 u)
    (kp-8 57407 u)
    (kp-9 57408 u)
    (kp-decimal 57409 u)
    (dp-divide 57410 u)
    (kp-multiply 57411 u)
    (kp-subtract 57412 u)
    (kp-add 57413 u)
    (kp-enter 57414 u)
    (kp-left 57417 u)
    (kp-right 57418 u)
    (kp-up 57419 u)
    (kp-down 57420 u)
    (kp-prior 57421 u)
    (kp-next 57422 u)
    (kp-home 57423 u)
    (kp-end 57424 u)
    (kp-insert 57425 u)
    (kp-delete 57426 u)
    (kp-begin 1 E)
    (kp-begin 57427 ~))
  "A list whose item is in the form of (KEY-SYMBOL NUMBER SUFFIX).
These keys are missing because Emacs cannot recognize it when only it
is pressed: CAPS_LOCK NUM_LOCK LEFT_* RIGHT_*
These keys are missing because they are not on my keyboard: MENU
KP_EQUAL KP_SEPARATOR MEDIA_* *_VOLUME ISO_*
Refer to
https://sw.kovidgoyal.net/kitty/keyboard-protocol/#functional-key-definitions
for more information.")

(defconst kitty-keyboard-protocol-modifier-sets
  (let ((needed (list
                 (kitty-keyboard-protocol--modifier-set-make :keys nil
                                                             :value 1)
                 (kitty-keyboard-protocol--modifier-set-make :keys '(shift)
                                                             :value 2)
                 (kitty-keyboard-protocol--modifier-set-make :keys '(meta)
                                                             :value 3)
                 (kitty-keyboard-protocol--modifier-set-make :keys '(control)
                                                             :value 5)
                 (kitty-keyboard-protocol--modifier-set-make :keys '(shift meta)
                                                             :value 4)
                 (kitty-keyboard-protocol--modifier-set-make :keys '(shift control)
                                                             :value 6)
                 (kitty-keyboard-protocol--modifier-set-make :keys '(meta control)
                                                             :value 7)
                 (kitty-keyboard-protocol--modifier-set-make :keys '(shift meta control)
                                                             :value 8)))
	ignored)
    ;; to ignore n modifiers, we need to deal with (2^n-1) different sets of ignored modifiers
    ;; TODO find a good way to do so when we start to ignore more than one modifiers
    (dolist (modifier-set needed)
      ;; ignore num_lock
      (push (kitty-keyboard-protocol--modifier-set-make
             :keys (kitty-keyboard-protocol--modifier-set-keys modifier-set)
             :value (+ (kitty-keyboard-protocol--modifier-set-value modifier-set) 128))
            ignored))
    (append needed ignored))
  "A list of `kitty-keyboard-protocol--modifier-set'.

Implemented modifiers: shift, meta (alt in the spec), and control
(crtl in the spec).

Ignored modifiers: num_lock

Not implemented modifiers: super, hyper, meta, caps_lock

Refer to https://sw.kovidgoyal.net/kitty/keyboard-protocol/#modifiers
for more information.")

(defun kitty-keyboard-protocol--key-table-item-key (key-table-item)
  "Return the key of KEY-TABLE-ITEM."
  (car key-table-item))

(defun kitty-keyboard-protocol--key-table-item-number (key-table-item)
  "Return the number of KEY-TABLE-ITEM."
  (cadr key-table-item))

(defun kitty-keyboard-protocol--key-table-item-suffix (key-table-item)
  "Return the suffix of KEY-TABLE-ITEM."
  (caddr key-table-item))

;; TODO take keyboard layout into consideration
;; `quail-keyboard-layout' `quail-set-keyboard-layout'
(defun kitty-keyboard-protocol--shift-key (key)
  "Return the shifted KEY, e.g. `a' -> `A', `1' -> `!'."
  (cond ((= key ?`) ?~)
	((= key ?-) ?_)
	((= key ?=) ?+)
	((= key ?\[) ?{)
	((= key ?\]) ?})
	((= key ?\\) ?|)
	((= key ?\;) ?:)
	((= key ?') ?\")
	((= key ?,) ?<)
	((= key ?.) ?>)
	((= key ?/) ??)
	((= key ?1) ?!)
	((= key ?2) ?@)
	((= key ?3) ?#)
	((= key ?4) ?$)
	((= key ?5) ?%)
	((= key ?6) ?^)
	((= key ?7) ?&)
	((= key ?8) ?*)
	((= key ?9) ?\()
	((= key ?0) ?\))
	((= key ? ) ? )
	((and (<= ?a key)
	      (<= key ?z))
	 (- key 32))
	(t (error "%s" "This error should never be signaled"))))

(defun kitty-keyboard-protocol--generate-keymap-item-input-event
    (number suffix modifier-value is-text-key)
  "Return input events to be used in a keymap item."
  (cond ((and is-text-key
	      (= modifier-value 1))
	 (format "%c" number))
	((and is-text-key
	      (= modifier-value 2))
	 (format "%c" (kitty-keyboard-protocol--shift-key number)))
	((and (not is-text-key)
	      (= number 1)
	      (= modifier-value 1))
	 (format "\e\[%s" suffix))
	((and (not is-text-key)
	      (not (= number 1))
	      (= modifier-value 1))
	 (format "\e\[%d%s" number suffix))
	(t
	 (format "\e\[%d;%d%s" number modifier-value suffix))))

(defun kitty-keyboard-protocol--generate-keymap-item-key-sequence
    (key modifier-keys is-text-key)
  "Return a key sequence to be used in a keymap item."
  (vector (cond ((and is-text-key
		      (equal modifier-keys '(shift)))
		 (list (kitty-keyboard-protocol--shift-key key)))
		((and is-text-key
		      (memq 'shift modifier-keys)
		      (not (equal modifier-keys '(shift)))
		      (not (and (<= ?a key)
				(<= key ?z))))
		 (reverse (cons (kitty-keyboard-protocol--shift-key key)
				(remq 'shift modifier-keys))))
		(t
		 (reverse (cons key modifier-keys))))))

(iter-defun kitty-keyboard-protocol--generate-keymap-item (key-table is-text-key)
  "Return an iterator applying modifiers to the item of KEY-TABLE.
Each value of the iterator is a keymap-item in form of (INPUT-EVENT
. KEY-SEQUENCE).
It takes IS-TEXT-KEY into consideration."
  (dolist (key-table-item key-table)
    (let ((key (kitty-keyboard-protocol--key-table-item-key key-table-item))
	  (number (kitty-keyboard-protocol--key-table-item-number key-table-item))
	  (suffix (kitty-keyboard-protocol--key-table-item-suffix key-table-item)))
      (dolist (modifier-set kitty-keyboard-protocol-modifier-sets)
	(iter-yield
	 (cons (kitty-keyboard-protocol--generate-keymap-item-input-event
                number
		suffix
		(kitty-keyboard-protocol--modifier-set-value modifier-set)
		is-text-key)
	       (kitty-keyboard-protocol--generate-keymap-item-key-sequence
                key
		(kitty-keyboard-protocol--modifier-set-keys modifier-set)
		is-text-key)))))))

(defun kitty-keyboard-protocol--keymap-item-input-event (keymap-item)
  "Return the input events of a KEYMAP-ITEM."
  (car keymap-item))

(defun kitty-keyboard-protocol--keymap-item-key-sequence (keymap-item)
  "Return the key sequence of a KEYMAP-ITEM."
  (cdr keymap-item))

(defconst kitty-keyboard-protocol-map
  (let ((map (make-sparse-keymap)))
    ;; TODO DRY twice
    (iter-do (keymap-item (kitty-keyboard-protocol--generate-keymap-item
			   kitty-keyboard-protocol-functional-key-table
			   nil))
      (let ((input-event (kitty-keyboard-protocol--keymap-item-input-event keymap-item))
	    (key-sequence (kitty-keyboard-protocol--keymap-item-key-sequence keymap-item)))
	(define-key map input-event key-sequence)))
    (iter-do (keymap-item (kitty-keyboard-protocol--generate-keymap-item
			   kitty-keyboard-protocol-text-key-table
			   t))
      (let ((input-event (kitty-keyboard-protocol--keymap-item-input-event keymap-item))
	    (key-sequence (kitty-keyboard-protocol--keymap-item-key-sequence keymap-item)))
	(define-key map input-event key-sequence)))
    ;; special case for Enter(0x0d), Backspace(ox7f or 0x08) and Tab(0x09)
    (define-key map [13] [return])
    (define-key map [127] [backspace])
    (define-key map [8] [backspace])
    (define-key map [9] [tab])
    map)
  "A keymap to decode input events using kitty keyboard protocol.")

(defun kitty-keyboard-protocol--push-map (map basemap)
  "Insert MAP between BASEMAP and the parent map of BASEMAP.
This function is copied from `xterm--push-map'."
  (set-keymap-parent basemap
		     (make-composed-keymap map (keymap-parent basemap))))

(defcustom kitty-keyboard-protocol-query-terminal-timeout 0.2
  "The number of seconds to wait for answers from a terminal."
  :group 'kitty-keyboard-protocol
  :type 'number)

(defun kitty-keyboard-protocol--query-terminal (query)
  "Return an event list as a answer for QUERY from a terminal.
This function takes `kitty-keyboard-protocol--query-terminal' seconds
to run."
  (let (event events)
    (send-string-to-terminal query)
    (while (setq event
		 (read-event nil nil kitty-keyboard-protocol-query-terminal-timeout))
      (push event events))
    events))

(defun kitty-keyboard-protocol--match-kitty-progressive-enhancement-p (events)
  "Return t if EVENTS match an answer for the progressive enhancement.
EVENTS is a list in the reverse order.
In fact, the non-nil return value is the current flags in decimal of
the terminal.
Refer to
https://sw.kovidgoyal.net/kitty/keyboard-protocol/#progressive-enhancement
for more information."
  (let ((len (length events))
	flags)
    (and (or (= len 5)
	     (= len 6))
	 (= (pop events) ?u)
	 ;; match "flags"
	 (let ((flag1 (cl-digit-char-p (pop events)))
	       flag2)
	   (if (= len 5)
	       (setq flags flag1)
	     (and (setq flag2 (cl-digit-char-p (pop events)))
		  (setq flags (+ (* flag2 10) flag1))
		  (< flags 32))))
	 ;; match "CSI ?"
	 (= (pop events) ??)
	 (= (pop events) ?\[)
	 (= (pop events) ?)
	 ;; return flags
	 flags)))

;; TODO match numbers and ";"s
(defun kitty-keyboard-protocol--match-primary-device-attributes-p (events)
  "Return t if EVENTS match an answer for primary device attributes.
EVENTS is a list in the reverse order.
Refer to https://vt100.net/docs/vt510-rm/DA1.html for more
information."
  (and (not (length< events 7)) ;; minimal events from vterm CSI ? 1 ; 2 c
       (= (pop events) ?c)
       (let ((reverse-events (reverse events)))
	 ;; match "CSI ?"
	 (and (= (pop reverse-events) ?)
	      (= (pop reverse-events) ?\[)
	      (= (pop reverse-events) ??)))))

(defun kitty-keyboard-protocol--support-p ()
  "Return t if the terminal supports kitty keyboard protocol.
In fact, the non-nil return value is the current flags in decimal of
the terminal.  Refer to
https://sw.kovidgoyal.net/kitty/keyboard-protocol/#detection-of-support-for-this-protocol
for more information.

This function calls `kitty-keyboard-protocol--query-terminal' twice,
so it needs double `kitty-keyboard-protocol-query-terminal-timeout'
seconds to run."
  (and (kitty-keyboard-protocol--match-primary-device-attributes-p
	(kitty-keyboard-protocol--query-terminal "\e\[c"))
       (kitty-keyboard-protocol--match-kitty-progressive-enhancement-p
	(kitty-keyboard-protocol--query-terminal "\e\[?u"))))

(defvar kitty-keyboard-protocol--terminals nil
  "Terminals where `kitty-keyboard-protocol-enable' has been called.
It is a list.")

;;;###autoload
(defun kitty-keyboard-protocol-enable (&optional flags)
  "Request a terminal to use kitty keyboard protocol defined by FLAGS.
FLAGS is a integer in decimal.  If FLAGS is nil, it defaults to 1,
meaning the \"disambiguate escape codes\" mode.
Even if the call of `kitty-keyboard-protocol--support-p' is t, the
terminal may not support our specific request. However, to reduce the
time this function needs to run, we do not verify the result of our
request.

This function should be added to `tty-setup-hook'."
  (when (kitty-keyboard-protocol--support-p)
    (kitty-keyboard-protocol--push-map kitty-keyboard-protocol-map input-decode-map)
    (send-string-to-terminal (format "\e\[>%su" (or flags 1)))
    (push (frame-terminal) kitty-keyboard-protocol--terminals)
    (message "kitty keyboard protocol: enabled")))

;; in the following case, we need to autoload this function
;;   1. loading of this package is deferred
;;   2. no tty terminal Emacs is created, i.e., this package is not
;;   autoloaded by `kitty-keyboard-protocol-enable'
;;   3. a frame is deleted so this function will be called and the
;;   package is still not loaded
;;;###autoload
(defun kitty-keyboard-protocol-disable (&optional frame)
  "Request the terminal to stop using kitty keyboard protocol.
FRAME is the frame to be close.

To run this when Emacs exits, it should be added to `kill-emacs-hook'.
To run this when emacsclient exits, it should be added to
`delete-frame-functions' instead of `after-delete-frame-functions'.
Doing so makes sure it is called in the current terminal.  Otherwise,
it is called in the Emacs server terminal, which doesn't make sense."
  (let ((terminal (frame-terminal frame)))
    ;; This check ensures:
    ;;   1. This function is only run once because functions in
    ;;   `delete-frame-functions' may be called more than once.
    ;;   2. This function is only run after
    ;;   `kitty-keyboard-protocol-enable' is called.
    (when (member terminal kitty-keyboard-protocol--terminals)
      (send-string-to-terminal "\e\[<u" terminal)
      (setq kitty-keyboard-protocol--terminals
	    (delete terminal kitty-keyboard-protocol--terminals)))))

(provide 'kitty-keyboard-protocol)

;;; kitty-keyboard-protocol.el ends here
