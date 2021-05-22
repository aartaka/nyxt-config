(in-package #:nyxt-user)

(define-configuration nyxt/web-mode:web-mode
  ;; QWERTY home row.
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:emacs scheme)
                      "C-c p" 'copy-password
                      "C-c y" 'autofill
                      "C-f" 'nyxt/web-mode:history-forwards-maybe-query
                      "C-i" 'nyxt/input-edit-mode:input-edit-mode)
                    scheme))))

(define-configuration nyxt::base-mode
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:emacs scheme)
                      "C-R" 'reload-current-buffer
                      "C-M-R" 'reload-buffers)
                    scheme))))
