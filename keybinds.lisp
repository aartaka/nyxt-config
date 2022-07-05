(in-package #:nyxt-user)

;;; Add basic keybindings.

(define-parenscript insert-text (text)
  (nyxt/ps:insert-at (ps:@ document active-element) (ps:lisp text)))

(defmacro construct-command (name (&rest args) &body body)
  `(#+nyxt-2 make-command
    #+nyxt-3 lambda-command
    ,name
    (,@args) ,@body))

(defmacro alter-keyscheme (keyscheme scheme-name &body bindings)
  #+nyxt-2
  `(let ((scheme ,keyscheme))
     (keymap:define-key (gethash ,scheme-name scheme)
       ,@bindings)
     scheme)
  #+nyxt-3
  `(nkeymaps/core:define-keyscheme-map "custom" (list :import ,keyscheme)
     ,scheme-name
     (list ,@bindings)))

;; nyxt/web-mode: is the package prefix. Usually is just nyxt/ and mode name.
;; Think of it as Emacs' package prefixes e.g. `org-' in `org-agenda' etc.
(define-configuration
    (#+nyxt-2 nyxt/web-mode:web-mode
     #+nyxt-3 nyxt/document-mode:document-mode)
  ((#+nyxt-2 keymap-scheme
    #+nyxt-3 keyscheme-map
    (alter-keyscheme
        %slot-default%
        ;; If you want to have VI bindings overriden, just use
        ;; `scheme:vi-normal' or `scheme:vi-insert' instead of
        ;; `scheme:emacs'.
        ;;
        ;; For 3.*, use `nyxt/scheme:' prefix instead.
        #+nyxt-2 scheme:emacs
      #+nyxt-3 nyxt/keyscheme:emacs
      "C-c p" 'copy-password
      "C-c y" 'autofill
      "C-f"
      #+nyxt-2 'nyxt/web-mode:history-forwards-maybe-query
      #+nyxt-3 'nyxt/history-mode:history-forwards-maybe-query
      "C-i" 'nyxt/input-edit-mode:input-edit-mode
      "M-:" 'eval-expression
      "C-s"
      #+nyxt-2 'nyxt/web-mode:search-buffer
      #+nyxt-3 'nyxt/search-buffer-mode:search-buffer
      "C-x 3" 'hsplit
      "C-x 1" 'close-all-panels
      "C-M-'"  (construct-command insert-left-angle-quote () (insert-text "«"))
      "C-M-\"" (construct-command insert-left-angle-quote () (insert-text "»"))
      "C-M-hyphen" (construct-command insert-left-angle-quote () (insert-text "—"))
      "C-M-_" (construct-command insert-left-angle-quote () (insert-text "–"))))))

#+nyxt-2
(define-configuration nyxt/auto-mode:auto-mode
  ((keymap-scheme
    (alter-keyscheme
        %slot-default%
        scheme:cua
      "C-R" nil))))

;;; Disable C-w, as it leads my Emacs muscle memory to shoot me in the foot.
;;;
;;; Shadowed by Emacs scheme's `nyxt/document-mode:cut' on 3.*.
#+nyxt-2
(define-configuration base-mode
  ((keymap-scheme
    (let ((scheme %slot-default%))
      (keymap:define-key (gethash scheme:cua scheme)
        ;; Alternatively, bind it to nil.
        "C-w" 'nothing)
      scheme))))
