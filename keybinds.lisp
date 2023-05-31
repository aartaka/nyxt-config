(in-package #:nyxt-user)

(define-configuration :document-mode
  "Add basic keybindings."
  ((keyscheme-map
    (keymaps:define-keyscheme-map
     "custom" (list :import %slot-value%)
     ;; If you want to have VI bindings overriden, just use
     ;; `scheme:vi-normal' or `scheme:vi-insert' instead of
     ;; `scheme:emacs'.
     nyxt/keyscheme:emacs
     (list "C-c p" 'copy-password
           "C-c y" 'autofill
           "C-f" :history-forwards-maybe-query
           "C-i" :input-edit-mode
           "M-:" 'eval-expression
           "C-s" :search-buffer
           "C-x 3" 'hsplit
           "C-x 1" 'close-all-panels
           "C-'"  (lambda-command insert-left-angle-quote ()
                    (ffi-buffer-paste (current-buffer) "«"))
           "C-M-'" (lambda-command insert-left-angle-quote ()
                     (ffi-buffer-paste (current-buffer) "»"))
           "C-M-hyphen" (lambda-command insert-left-angle-quote ()
                          (ffi-buffer-paste (current-buffer) "—"))
           "C-M-_" (lambda-command insert-left-angle-quote ()
                     (ffi-buffer-paste (current-buffer) "–"))
           "C-E" (lambda-command small-e-with-acute ()
                   (ffi-buffer-paste (current-buffer) "é"))
           "C-A" (lambda-command small-a-with-acute ()
                   (ffi-buffer-paste (current-buffer) "á"))
           "C-I" (lambda-command small-i-diaeresis ()
                   (ffi-buffer-paste (current-buffer) "ï"))
           "C-h hyphen" 'clcs-lookup)))))
