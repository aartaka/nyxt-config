(in-package #:nyxt-user)

;;;; This is a file with settings for my nx-kaomoji extension.
;;;; You can find it at https://github.com/aartaka/nx-kaomoji

;;; Add a single keybinding for the extension-provided `kaomoji-fill' command.
(define-configuration nyxt/web-mode:web-mode
  ((keymap-scheme (let ((scheme %slot-default%))
                    (keymap:define-key (gethash scheme:emacs scheme)
                      "C-c K" 'kaomoji-fill)
                    scheme))))
