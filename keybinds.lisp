(in-package #:nyxt-user)

(define-configuration nyxt/web-mode:web-mode
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:emacs scheme)
                      "C-c p" 'copy-password
                      "C-c y" 'autofill
                      "C-f" 'nyxt/web-mode:history-forwards-maybe-query
                      "C-i" 'nyxt/input-edit-mode:input-edit-mode)
                    scheme))))

(define-configuration nyxt/auto-mode:auto-mode
  ;; Need to override the C-R for reload-with-modes.
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:cua scheme)
                      "C-R" nil)
                    scheme))))
