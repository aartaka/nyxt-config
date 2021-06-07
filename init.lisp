(in-package #:nyxt-user)

(dolist (file (list (nyxt-init-file "keybinds.lisp")
                    (nyxt-init-file "passwd.lisp")
                    (nyxt-init-file "status.lisp")
                    (nyxt-init-file "style.lisp")))
  (load file))
(load-after-system :nx-search-engines (nyxt-init-file "search-engines.lisp"))
(load-after-system :nx-kaomoji (nyxt-init-file "kaomoji.lisp"))
(load-after-system :nx-ace (nyxt-init-file "ace.lisp"))
(load-after-system :slynk (nyxt-init-file "slynk.lisp"))

(define-configuration browser
  ((session-restore-prompt :never-restore)))

(define-configuration (buffer internal-buffer editor-buffer prompt-buffer)
  ((default-modes `(emacs-mode ,@%slot-default%))
   (download-engine :renderer)
   (current-zoom-ratio 1.25)
   (conservative-word-move t)))

(define-configuration (web-buffer nosave-buffer)
  ((default-modes `(emacs-mode
                    blocker-mode force-https-mode reduce-tracking-mode
                    auto-mode
                    ,@%slot-default%))))

(define-configuration prompt-buffer
  ((hide-single-source-header-p t)))

(define-configuration nosave-buffer
  ((default-modes `(proxy-mode ,@%slot-default%))))

(define-configuration nyxt/web-mode:web-mode
  ;; QWERTY home row.
  ((nyxt/web-mode:hints-alphabet "DSJKHLFAGNMXCWEIO")
   (glyph "ω")))

(define-configuration nyxt/auto-mode:auto-mode
  ((nyxt/auto-mode:prompt-on-mode-toggle t)
   (glyph "α")))
