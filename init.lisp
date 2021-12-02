(in-package #:nyxt-user)

;;; Load quicklisp. Not sure it works.
#-quicklisp
(let ((quicklisp-init
       (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

;;; Loading files from the same directory.
;;; Can be done individually per file, dolist is there to simplify it.
(dolist (file (list
               (nyxt-init-file "keybinds.lisp")
               (nyxt-init-file "passwd.lisp")
               (nyxt-init-file "status.lisp")
               (nyxt-init-file "style.lisp")))
  (load file))

;;; Loading extensions and third-party-dependent configs. See the
;;; matching files for where to find those extensions.
;;;
;;; Usually, though, it boils down to cloning a git repository into
;;; your `*extensions-path*' and adding a `load-after-system' line
;;; mentioning a config file for this extension.
(load-after-system :nx-search-engines (nyxt-init-file "search-engines.lisp"))
(load-after-system :nx-kaomoji (nyxt-init-file "kaomoji.lisp"))
;; ;; (load-after-system :nx-ace (nyxt-init-file "ace.lisp"))
(load-after-system :slynk (nyxt-init-file "slynk.lisp"))

(define-configuration browser
  ;; This is for Nyxt to never prompt me about restoring the previous session.
  ((session-restore-prompt :never-restore)
   (external-editor-program (list "gedit"))))

;;; Those are settings that every type of buffer should share.
(define-configuration (buffer internal-buffer editor-buffer prompt-buffer)
  ;; Emacs keybindings.
  ((default-modes `(emacs-mode ,@%slot-default%))
   ;; This overrides download engine to use WebKit instead of
   ;; Nyxt-native Dexador-based download engine. I don't remember why
   ;; I switched, though.
   (download-engine :renderer)
   ;; I'm weak on the eyes, so I want everything to be a bit
   ;; zoomed-in.
   (current-zoom-ratio 1.25)))

(define-configuration prompt-buffer
  ;; This is to hide the header is there's only one source.
  ;; There also used to be other settings to make prompt-buffer a bit
  ;; more minimalist, but those are internal APIs :(
  ((hide-single-source-header-p t)))

;; Basic modes setup for web-buffer.
(define-configuration web-buffer
  ((default-modes `(emacs-mode
                    auto-mode
                    blocker-mode force-https-mode reduce-tracking-mode
                    ,@%slot-default%))))

(define-configuration file-source
  ((supported-media-types '("mp3" "ogg" "mp4" "flv" "wmv" "webm" "mkv" "html"))))

;;; Enable proxy in nosave (private, incognito) buffers.
(define-configuration nosave-buffer
  ((default-modes `(proxy-mode ,@%slot-default%))))

(define-configuration nyxt/web-mode:web-mode
  ;; QWERTY home row.
  ((nyxt/web-mode:hints-alphabet "DSJKHLFAGNMXCWEIO")))

;;; This make auto-mode to prompt me about remembering this or that
;;; mode when I toggle it.
(define-configuration nyxt/auto-mode:auto-mode
  ((nyxt/auto-mode:prompt-on-mode-toggle t)))

;;; Setting WebKit-specific settings. Not exactly the best way to
;;; configure Nyxt. See
;;; https://webkitgtk.org/reference/webkit2gtk/stable/WebKitSettings.html
;;; for the full list of settings you can tweak this way.
(defmethod ffi-buffer-make :after ((buffer gtk-buffer))
  (let ((settings (webkit:webkit-web-view-get-settings (nyxt::gtk-object buffer))))
    (setf
     ;; Resizeable textareas. It's not perfect, but still a cool feature to have.
     (webkit:webkit-settings-enable-resizable-text-areas settings) t
     ;; Write console errors/warnings to the shell, to ease debugging.
     (webkit:webkit-settings-enable-write-console-messages-to-stdout settings) t
     ;; "Inspect element" context menu option available at any moment.
     (webkit:webkit-settings-enable-developer-extras settings) t)))

;;; reduce-tracking-mode has a preferred-user-agent slot that it uses
;;; as the User Agent to set when enabled. What I want here is to have
;;; the same thing as reduce-tracking-mode, but with a different User
;;; Agent.
(define-mode chrome-mimick-mode (nyxt/reduce-tracking-mode:reduce-tracking-mode)
  "A simple mode to set Chrome-like Windows user agent."
  ((nyxt/reduce-tracking-mode:preferred-user-agent
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36")))

(define-mode firefox-mimick-mode (nyxt/reduce-tracking-mode:reduce-tracking-mode)
  "A simple mode to set Firefox-like Linux user agent."
  ((nyxt/reduce-tracking-mode:preferred-user-agent
    "Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0")))

(define-command-global eval-expression ()
  "Prompt for the expression and evaluate it, echoing result to the `message-area'."
  (let ((expression-string
          ;; Read an arbitrary expression. No error checking, though.
          (first (prompt :prompt "Expression to evaluate"
                         :sources (list (make-instance 'prompter:raw-source))))))
    ;; Message the evaluation result to the message-area down below.
    (echo "~S" (eval (read-from-string expression-string)))))

(define-command-global describe-all ()
  "Prompt for a symbol in any Nyxt-accessible package and describe it in the best way Nyxt can."
  (let* ((all-symbols (apply #'append (loop for package in (list-all-packages)
                                            collect (loop for sym being the external-symbols in package
                                                          collect sym))))
         ;; All copied from /nyxt/source/help.lisp with `describe-any' as a reference.
         (classes (remove-if (lambda (sym)
                               (not (and (find-class sym nil)
                                         (mopu:subclassp (find-class sym) (find-class 'standard-object)))))
                             all-symbols))
         (slots (alexandria:mappend (lambda (class-sym)
                                      (mapcar (lambda (slot) (make-instance 'nyxt::slot
                                                                            :name slot
                                                                            :class-sym class-sym))
                                              (nyxt::class-public-slots class-sym)))
                                    classes))
         (functions (remove-if (complement #'fboundp) all-symbols))
         (variables (remove-if (complement #'boundp) all-symbols)))
    (prompt
     :prompt "Describe:"
     :sources (list (make-instance 'nyxt::variable-source :constructor variables)
                    (make-instance 'nyxt::function-source :constructor functions)
                    (make-instance 'nyxt::user-command-source
                                   :actions (list (make-unmapped-command describe-command)))
                    (make-instance 'nyxt::class-source :constructor classes)
                    (make-instance 'nyxt::slot-source :constructor slots)))))
