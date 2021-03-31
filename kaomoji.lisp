(in-package #:nyxt-user)

(define-configuration buffer
  ((override-map (keymap:define-key %slot-default
                   "C-c K" 'kaomoji-fill))))
