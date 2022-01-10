(in-package #:nyxt-user)

;;; Add basic keybindings.

;; nyxt/web-mode: is the package prefix. Usually is just nyxt/ and mode name.
;; Think of it as Emacs' package prefixes e.g. `org-' in `org-agenda' etc.
(define-configuration nyxt/web-mode:web-mode
  ((nyxt/web-mode::keymap-scheme
    ;; This will only works in >2.2.1. Change it to the hash-table way
    ;; below to make it work in <2.2.
    (nyxt::define-scheme (:name-prefix "web" :import %slot-default%)
      ;; If you want to have VI bindings overriden, just use
      ;; `scheme:vi-normal' or `scheme:vi-insert' instead of
      ;; `scheme:emacs'.
      scheme:emacs
      (list
       "C-c p" 'copy-password
       "C-c y" 'autofill
       "C-f" 'nyxt/web-mode:history-forwards-maybe-query
       "C-i" 'nyxt/input-edit-mode:input-edit-mode
       "M-:" 'eval-expression)))))

(define-configuration nyxt/auto-mode:auto-mode
  ;; An example of a low-level keybinding configuration.
  ;; `keymap-scheme' hosts several schemes inside a hash-table, thus
  ;; the `gethash' business.
  ;; Beware: you'll need to create the missing schemes:
  ;;   (unless (gethash scheme:vi-insert scheme)
  ;;     (setf (gethash scheme:vi-insert scheme)
  ;;           (make-keymap (format nil "~a-~a-map" "web" (keymap:name scheme:vi-insert)))))
  ((nyxt/auto-mode::keymap-scheme
    (let ((scheme %slot-default%))
      (keymap:define-key (gethash scheme:cua scheme)
        ;; Need to override the C-R for reload-with-modes.
        "C-R" nil)
      scheme))))

;;; Disable C-w, as it leads my Emacs muscle memory to shoot me in the foot.
(define-configuration base-mode
  ((keymap-scheme
    ;; Alternatively, from 2.2.1 on, use the new syntax (see web-mode config above).
    (let ((scheme %slot-default%))
      (keymap:define-key (gethash scheme:cua scheme)
        ;; Alternatively, bind it to nil.
        "C-w" 'nothing)
      scheme))))
