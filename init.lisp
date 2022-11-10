(in-package #:nyxt-user)

;;; Reset ASDF registries to allow loading Lisp systems from
;;; everywhere.
#+nyxt-3 (reset-asdf-registries)

;;; Load quicklisp. Not sure it works.
#-quicklisp
(let ((quicklisp-init
       (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))

(defvar *web-buffer-modes*
  '(nyxt/emacs-mode:emacs-mode nyxt/auto-mode:auto-mode
    nyxt/blocker-mode:blocker-mode nyxt/force-https-mode:force-https-mode
    nyxt/reduce-tracking-mode:reduce-tracking-mode
    #+nyxt-3 nyxt/user-script-mode:user-script-mode
    #+nyxt-3 nyxt/bookmarklets-mode:bookmarklets-mode)
  "The modes to enable in web-buffer by default.
Extension files (like dark-reader.lisp) are to append to this list.

Why the variable? Because it's too much hassle copying it everywhere.")

;;; Loading files from the same directory.
;;; Can be done individually per file, dolist is there to simplify it.
#+nyxt-3
(define-nyxt-user-system-and-load nyxt-user/basic-config
  :components ("keybinds" "passwd" "status" "commands" "style" "unpdf"))
#+nyxt-2
(dolist (file (list
               (nyxt-init-file "keybinds.lisp")
               (nyxt-init-file "passwd.lisp")
               (nyxt-init-file "status.lisp")
               (nyxt-init-file "commands.lisp")))
  (load file))

;;; Loading extensions and third-party-dependent configs. See the
;;; matching files for where to find those extensions.
;;;
;;; Usually, though, it boils down to cloning a git repository into
;;; your `*extensions-path*' (usually ~/.local/share/nyxt/extensions)
;;; and adding a `load-after-system' (Nyxt 2) /
;;; `define-nyxt-user-system-and-load' (Nyxt 3) line mentioning a
;;; config file for this extension.
(defmacro load-after-system* (system file)
  #+nyxt-2
  `(load-after-system ,system (nyxt-init-file ,(if (str:ends-with-p ".lisp" file)
                                                   file
                                                   (str:concat file ".lisp"))))
  #+nyxt-3
  `(define-nyxt-user-system-and-load ,(gensym "NYXT-USER/")
     :depends-on (,system) :components (,file)))

(load-after-system* :nx-search-engines "search-engines")
(load-after-system* :nx-kaomoji "kaomoji")
(load-after-system* :nx-ace "ace.lisp")
#+nyxt-2 (load-after-system* :slynk "slynk")
(load-after-system* :nx-freestance-handler "freestance")
#+nyxt-3 (load-after-system* :nx-dark-reader "dark-reader")

(flet ((construct-autofill (&rest args)
         (apply #+nyxt-2 #'make-autofill
                #+nyxt-3 #'nyxt/autofill-mode:make-autofill
                args)))
  (defvar *autofills*
    (list (construct-autofill :name "Crunch" :fill "Ну что, кранчим сегодня в Дискорде?")
          *debug-autofill*)))

(define-configuration browser
  (#+nyxt-2
   (autofills *autofills*)
   (external-editor-program
    (list "emacsclient" "-cn" "-a" "" "-F"
          "((font . \"IBM Plex Mono-17\") (vertical-scroll-bars) (tool-bar-lines) (menu-bar-lines))"))))

;;; Autofils are abstracted into a mode of their own on 3.*.
#+nyxt-3
(define-configuration nyxt/autofill-mode:autofill-mode
  ((nyxt/autofill-mode:autofills *autofills*)))

;;; Those are settings that every type of buffer should share.
(define-configuration (web-buffer prompt-buffer nyxt/editor-mode:editor-buffer)
  ;; Emacs keybindings.
  ((default-modes `(nyxt/emacs-mode:emacs-mode
                    #+nyxt-3 ,@%slot-value%
                    #+nyxt-2 ,@%slot-default%))))

(define-configuration web-buffer
  ;; This overrides download engine to use WebKit instead of
  ;; Nyxt-native Dexador-based download engine. I don't remember why
  ;; I switched, though.
  ((download-engine :renderer)
   ;; I'm weak on the eyes, so I want everything to be a bit
   ;; zoomed-in.
   (current-zoom-ratio 1.25)
   ;; I don't like search completion when I don't need it.
   #+nyxt-3
   (search-always-auto-complete-p nil)))

(define-configuration prompt-buffer
  ;; This is to hide the header is there's only one source.
  ;; There also used to be other settings to make prompt-buffer a bit
  ;; more minimalist, but those are internal APIs :(
  ((hide-single-source-header-p t)))

;; Basic modes setup for web-buffer.
(define-configuration web-buffer
  ((default-modes `(,@*web-buffer-modes*
                    #+nyxt-3 ,@%slot-value%
                    #+nyxt-2 ,@%slot-default%))))

;;; Set new buffer URL (a.k.a. start page, new tab page).
;;; It does not change the first buffer opened if you're on 2.*.
#+nyxt-2
(define-configuration buffer
  ((default-new-buffer-url "https://github.com")))
#+nyxt-3
(define-configuration browser
  ((default-new-buffer-url (quri:uri "https://github.com"))))

;;; Enable proxy in nosave (private, incognito) buffers.
(define-configuration nosave-buffer
  ((default-modes `(nyxt/proxy-mode:proxy-mode
                    ,@*web-buffer-modes*
                    #+nyxt-3 ,@%slot-value%
                    #+nyxt-2 ,@%slot-default%))))

;;; Set up QWERTY home row as the hint keys.
#+nyxt-2
(define-configuration nyxt/web-mode:web-mode
  ((nyxt/web-mode:hints-alphabet "DSJKHLFAGNMXCWEIO")))
#+nyxt-3
(define-configuration nyxt/hint-mode:hint-mode
  ((nyxt/hint-mode:hints-alphabet "DSJKHLFAGNMXCWEIO")
   ;; Same as default except it doesn't hint images
   (nyxt/hint-mode:hints-selector "a, button, input, textarea, details, select")))

;;; This makes auto-mode to prompt me about remembering this or that
;;; mode when I toggle it.
(define-configuration nyxt/auto-mode:auto-mode
  ((nyxt/auto-mode:prompt-on-mode-toggle t)))

;;; Setting WebKit-specific settings. Not exactly the best way to
;;; configure Nyxt. See
;;; https://webkitgtk.org/reference/webkit2gtk/stable/WebKitSettings.html
;;; for the full list of settings you can tweak this way.
(defmethod ffi-buffer-make :after ((buffer buffer))
  (let* ((settings (webkit:webkit-web-view-get-settings (nyxt::gtk-object buffer))))
    (setf
     ;; Resizeable textareas. It's not perfect, but still a cool feature to have.
     (webkit:webkit-settings-enable-resizable-text-areas settings) t
     ;; Write console errors/warnings to the shell, to ease debugging.
     (webkit:webkit-settings-enable-write-console-messages-to-stdout settings) t
     ;; "Inspect element" context menu option available at any moment.
     (webkit:webkit-settings-enable-developer-extras settings) t
     ;; Use Cantarell-18 as the default font.
     (webkit:webkit-settings-default-font-family settings) "Cantarell"
     (webkit:webkit-settings-default-font-size settings) 18
     ;; Use Hack-17 as the monospace font.
     (webkit:webkit-settings-monospace-font-family settings) "Hack"
     (webkit:webkit-settings-default-monospace-font-size settings) 17)))

#+nyxt-3
(define-configuration nyxt/reduce-tracking-mode:reduce-tracking-mode
  ((nyxt/reduce-tracking-mode:preferred-user-agent
    ;; Safari on Mac. Taken from
    ;; https://techblog.willshouse.com/2012/01/03/most-common-user-agents
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.3 Safari/605.1.15")))

;;; reduce-tracking-mode has a preferred-user-agent slot that it uses
;;; as the User Agent to set when enabled. What I want here is to have
;;; the same thing as reduce-tracking-mode, but with a different User
;;; Agent.
#+nyxt-3
(define-mode chrome-mimick-mode (nyxt/reduce-tracking-mode:reduce-tracking-mode)
  "A simple mode to set Chrome-like Windows user agent."
  ((nyxt/reduce-tracking-mode:preferred-user-agent
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/95.0.4638.69 Safari/537.36")))

#+nyxt-3
(define-mode firefox-mimick-mode (nyxt/reduce-tracking-mode:reduce-tracking-mode)
  "A simple mode to set Firefox-like Linux user agent."
  ((nyxt/reduce-tracking-mode:preferred-user-agent
    "Mozilla/5.0 (X11; Linux x86_64; rv:94.0) Gecko/20100101 Firefox/94.0")))

;; Enable Nyxt-internal debugging, but only in binary mode and after
;; startup if done (there are conditions raised at startup, and I
;; don't want to catch those, hanging my Nyxt).
(unless nyxt::*run-from-repl-p*
  (hooks:add-hook *after-startup-hook* #'toggle-debug-on-error))
