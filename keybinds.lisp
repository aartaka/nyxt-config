(in-package #:nyxt-user)

;;; Add basic keybindings.
;;;
;;; If you want to have VI bindings overriden, just use `scheme:vi'
;;; instead of `scheme:emacs'.
;;;
;;; `keymap-scheme' hosts several schemes inside a has-table, thus the
;;; `gethash' business
(define-configuration nyxt/web-mode:web-mode
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:emacs scheme)
                      "C-c p" 'copy-password
                      "C-c y" 'autofill
                      "C-f" 'nyxt/web-mode:history-forwards-maybe-query
                      "C-i" 'nyxt/input-edit-mode:input-edit-mode
                      "M-:" 'eval-expression)
                    scheme))))

(define-configuration nyxt/auto-mode:auto-mode
  ;; Need to override the C-R for reload-with-modes.
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:cua scheme)
                      "C-R" nil)
                    scheme))))
