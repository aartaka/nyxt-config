(in-package #:nyxt-user)

;;;; This is a file with settings for my nx-kaomoji extension.
;;;; You can find it at https://github.com/aartaka/nx-kaomoji

(define-configuration :document-mode
  "Add a single keybinding for the extension-provided `kaomoji-fill' command."
  ((keymap-scheme
    (alter-keyscheme %slot-value% nyxt/keyscheme:emacs
     "C-c K" 'nx-kaomoji:kaomoji-fill))))
