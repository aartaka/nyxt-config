(in-package #:nyxt-user)

(define-configuration nyxt/web-mode:web-mode
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:emacs scheme)
                      "C-c K" 'kaomoji-fill)
                    scheme))))
