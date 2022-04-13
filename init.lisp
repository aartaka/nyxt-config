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
  '(emacs-mode auto-mode blocker-mode force-https-mode reduce-tracking-mode)
  "The modes to enable in web-buffer by default.
Extension files (like dark-reader.lisp) are to append to this list.

Why the variable? Because one can only set `default-modes' once, so I
need to dynamically construct a list of modes and configure the slot
only after it's done.")

(defvar *request-resource-handlers*
  nil
  "The list of handlers to add to `request-resource-hook'.

These handlers are usually used to block/redirect the requests.")

;;; Loading files from the same directory.
;;; Can be done individually per file, dolist is there to simplify it.
(dolist (file (list
               (nyxt-init-file "keybinds.lisp")
               (nyxt-init-file "passwd.lisp")
               (nyxt-init-file "status.lisp")
               (nyxt-init-file "commands.lisp")
               #+nyxt-3
               ;; My styling depends on `theme' introduced in Nyxt 3.
               (nyxt-init-file "style.lisp")))
  (load file))

;;; Loading extensions and third-party-dependent configs. See the
;;; matching files for where to find those extensions.
;;;
;;; Usually, though, it boils down to cloning a git repository into
;;; your `*extensions-path*' (usually ~/.local/share/nyxt/extensions)
;;; and adding a `load-after-system' line mentioning a config file for
;;; this extension.
(load-after-system :nx-search-engines (nyxt-init-file "search-engines.lisp"))
(load-after-system :nx-kaomoji (nyxt-init-file "kaomoji.lisp"))
;; ;; (load-after-system :nx-ace (nyxt-init-file "ace.lisp"))
(load-after-system :slynk (nyxt-init-file "slynk.lisp"))
(load-after-system :nx-freestance-handler (nyxt-init-file "freestance.lisp"))
#+nyxt-3
(load-after-system :nx-dark-reader (nyxt-init-file "dark-reader.lisp"))

;; Turn the Nyxt-native debugging on. Only works in Nyxt 3.
#+nyxt-3 (toggle-debug-on-error :value t)

(define-configuration browser
  ;; This is for Nyxt to never prompt me about restoring the previous session.
  ((session-restore-prompt :never-restore)
   (autofills (list (make-autofill :name "Crunch" :fill "Ну что, кранчим сегодня в Дискорде?")))
   (external-editor-program
    (list "emacsclient" "-cn" "-a" "" "-F"
          "((font . \"IBM Plex Mono-17\") (vertical-scroll-bars)(tool-bar-lines) (menu-bar-lines))"))))

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
  ((default-modes (append *web-buffer-modes* %slot-default%))
   (request-resource-hook
    (reduce #'hooks:add-hook
            *request-resource-handlers*
            :initial-value %slot-default%))))

;;; Set new buffer URL (a.k.a. start page, new tab page).
;;; It does not change the first buffer opened if you're on 2.*.
(define-configuration
  #+nyxt-2 buffer
  #+nyxt-3 browser
  ((default-new-buffer-url (quri:uri "https://github.com"))))

;;; Enable proxy in nosave (private, incognito) buffers.
(define-configuration nosave-buffer
  ((default-modes (append '(proxy-mode) *web-buffer-modes* %slot-default%))))

(define-configuration nyxt/web-mode:web-mode
  ;; QWERTY home row.
  ((nyxt/web-mode:hints-alphabet "DSJKHLFAGNMXCWEIO")
   ;; (nyxt/web-mode:user-scripts
   ;;  (mapcar
   ;;   #'make-greasemonkey-script
   ;;   (list
   ;;    "https://greasyfork.org/scripts/7543-google-search-extra-buttons/code/Google%20Search%20Extra%20Buttons.user.js"
   ;;    (quri:url-encode "https://greasyfork.org/scripts/14146-网页限制解除/code/网页限制解除.user.js")
   ;;    "https://greasyfork.org/scripts/423851-simple-youtube-age-restriction-bypass/code/Simple%20YouTube%20Age%20Restriction%20Bypass.user.js"
   ;;    "https://greasyfork.org/scripts/38182-hide-youtube-google-ad/code/Hide%20youtube%20google%20ad.user.js"
   ;;    "https://greasyfork.org/scripts/4870-maximize-video/code/Maximize%20Video.user.js"
   ;;    "https://greasyfork.org/scripts/370246-sci-hub-button/code/Sci-hub%20button.user.js")))
   ))

;;; This makes auto-mode to prompt me about remembering this or that
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
     (webkit:webkit-settings-enable-developer-extras settings) t
     ;; Use Cantarell-18 as the default font.
     (webkit:webkit-settings-default-font-family settings) "Cantarell"
     (webkit:webkit-settings-default-font-size settings) 18)))

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
