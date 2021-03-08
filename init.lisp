(in-package #:nyxt-user)

(asdf:load-asd "/home/aartaka/git/nx-search-engines/nx-search-engines.asd")
(load-after-system :nx-search-engines (nyxt-init-file "search-engines.lisp"))
(load-after-system :slynk (nyxt-init-file "slynk.lisp"))
(dolist (file (list (nyxt-init-file "passwd.lisp")
                    (nyxt-init-file "status.lisp")
                    (nyxt-init-file "style.lisp")))
  (load file))

(define-configuration browser
  ((session-restore-prompt :never-restore)
   (autofills (list (nyxt::make-autofill :key "Shrug" :fill "¯\_(ツ)_/¯")
                    (nyxt::make-autofill :key "Name"  :fill "Artyom Bologov")
                    (nyxt::make-autofill :key "Signature" :fill "Best of luck,
--
Artyom.")))))

(define-configuration buffer
  ((default-modes `(emacs-mode ,@%slot-default))
   (download-engine :renderer)
   (conservative-word-move t)
   (override-map (keymap:define-key %slot-default
                   "C-c p c" 'copy-password
                   "C-c p s" 'save-new-password
                   "C-f" 'nyxt/web-mode:history-forwards-maybe-query))))

(define-configuration (web-buffer nosave-buffer)
  ((default-modes `(emacs-mode auto-mode blocker-mode force-https-mode reduce-tracking-mode
                               ,@%slot-default))))

(define-configuration nyxt/web-mode:web-mode
  ;; QWERTY home row.
  ((nyxt/web-mode:hints-alphabet "DSJKHLFAGNMXCWEIO")))

(define-configuration nyxt/auto-mode:auto-mode
  ((nyxt/auto-mode:prompt-on-mode-toggle t)))
