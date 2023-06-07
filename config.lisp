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
  '(:emacs-mode
    :blocker-mode :force-https-mode
    :reduce-tracking-mode
    :user-script-mode :bookmarklets-mode)
  "The modes to enable in any web-buffer by default.
Extension files (like dark-reader.lisp) are to append to this list.

Why the variable? Because it's too much hassle copying it everywhere.")

;;; Loading files from the same directory.
(define-nyxt-user-system-and-load nyxt-user/basic-config
  :components ("keybinds" "passwd" "status" "commands" "hsplit" "style" "unpdf" "objdump" "github"))

;;; Loading extensions and third-party-dependent configs. See the
;;; matching files for where to find those extensions.
(defmacro defextsystem (system &optional file)
  "Helper macro to load configuration for extensions.
Loads a newly-generated ASDF system depending on SYSTEM.
FILE, if provided, is loaded after the generated system successfully
loads."
  `(define-nyxt-user-system-and-load ,(gensym "NYXT-USER/")
     :depends-on (,system) ,@(when file
                               `(:components (,file)))))

(defextsystem :nx-search-engines "search-engines")
(defextsystem :nx-kaomoji "kaomoji")
(defextsystem :nx-ace "ace.lisp")
(defextsystem :nx-fruit)
(defextsystem :nx-freestance-handler "freestance")
(defextsystem :nx-dark-reader "dark-reader")

(define-configuration browser
  ;; Enable --remote --eval code evaluation.
  ((remote-execution-p t)
   (external-editor-program
    (list "emacsclient" "-cn" "-a" "" "-F"
          "((font . \"IBM Plex Mono-17\") (vertical-scroll-bars) (tool-bar-lines) (menu-bar-lines))"))))

(define-configuration :autofill-mode
  "Setting up autofills."
  ((autofills (flet ((autofill (name fill)
                               (nyxt/mode/autofill:make-autofill :name name :fill fill)))
                    (list (autofill "naive" "naïve")
                          (autofill "andre" "André")
                          (autofill "ala" "a-lá")
                          (autofill "let" "laisser-faire"))))))

;;; Those are settings that every type of buffer should share.
(define-configuration (:modable-buffer :prompt-buffer :editor-buffer)
  "Set up Emacs keybindings everywhere possible."
  ((default-modes `(:emacs-mode ,@%slot-value%))))

(define-configuration :prompt-buffer
  "Make the attribute widths adjust to the content in them.

It's not exactly necessary on master, because there are more or less
intuitive default widths, but these are sometimes inefficient (and
note that I made this feature so I want to have it :P)."
  ((dynamic-attribute-width-p t)))

(define-configuration :web-buffer
  ((download-engine
    :renderer
    :doc "This overrides download engine to use WebKit instead of Nyxt-native
Dexador-based download engine. I don't remember why I switched,
though.")
   (search-always-auto-complete-p
    nil
    :doc "I don't like search completion when I don't need it.")
   (global-history-p
    t
    :doc "It was disabled after 2.2.4, while being a useful feature.
I'm forcing it here, because I'm getting lost in buffer-local
histories otherwise...")))

(define-configuration :prompt-buffer
  ((hide-single-source-header-p
    t
    :doc "This is to hide the header is there's only one source.
There also used to be other settings to make prompt-buffer a bit
more minimalist, but those are internal APIs :(")))

(define-configuration :web-buffer
  "Basic modes setup for web-buffer."
  ((default-modes `(,@*web-buffer-modes* ,@%slot-value%))))

(define-configuration :browser
  "Set new buffer URL (a.k.a. start page, new tab page)."
  ((default-new-buffer-url (quri:uri "nyxt:nyxt/mode/repl:repl"))))

(define-configuration :nosave-buffer
  "Enable proxy in nosave (private, incognito) buffers."
  ((default-modes `(:proxy-mode ,@*web-buffer-modes* ,@%slot-value%))))

(define-configuration :hint-mode
  "Set up QWERTY home row as the hint keys."
  ((hints-alphabet "DSJKHLFAGNMXCWEIO")))

(define-configuration :history-mode
  ((backtrack-to-hubs-p
    t
    :doc "I often browse with \"hub\" places, like GitHub notifications page.
Having all the links it leads to to be forward children of it is useful.
The feature is slightly experimental, though.")))

(define-configuration :modable-buffer
  "This makes auto-rules to prompt me about remembering this or that mode when I toggle it."
  ((prompt-on-mode-toggle-p t)))

(defmethod ffi-buffer-make :after ((buffer nyxt/renderer/gtk::gtk-buffer))
  "Setting WebKit-specific settings.
WARNING: Not exactly the best way to configure Nyxt, because it relies
on internal APIs and CFFI...

See
https://webkitgtk.org/reference/webkit2gtk/stable/WebKitSettings.html
for the full list of settings you can tweak this way."
  (when (slot-boundp buffer 'nyxt/renderer/gtk::gtk-object)
    (let* ((settings (webkit:webkit-web-view-get-settings
                      (nyxt/renderer/gtk::gtk-object buffer))))
      (setf
       ;; Resizeable textareas. It's not perfect, but still a cool feature to have.
       (webkit:webkit-settings-enable-resizable-text-areas settings) t
       ;; Write console errors/warnings to the shell, to ease debugging.
       (webkit:webkit-settings-enable-write-console-messages-to-stdout settings) t
       ;; "Inspect element" context menu option available at any moment.
       (webkit:webkit-settings-enable-developer-extras settings) t
       ;; Enable WebRTC.
       (webkit:webkit-settings-enable-media-stream settings) t
       ;; Use Cantarell-18 as the default font.
       (webkit:webkit-settings-default-font-family settings) "Cantarell"
       (webkit:webkit-settings-default-font-size settings) 18
       ;; Use Hack-17 as the monospace font.
       (webkit:webkit-settings-monospace-font-family settings) "Hack"
       (webkit:webkit-settings-default-monospace-font-size settings) 17
       ;; Use Unifont for pictograms.
       (webkit:webkit-settings-pictograph-font-family settings) "Unifont")))
  ;; Set the view background to black.
  (cffi:foreign-funcall
   "webkit_web_view_set_background_color"
   :pointer (g:pointer (nyxt/renderer/gtk:gtk-object buffer))
   ;; GdkRgba is simply an array of four doubles.
   :pointer (cffi:foreign-alloc
             :double
             :count 4
             ;; red green blue alpha
             :initial-contents '(0d0 0d0 0d0 1d0))))

(defmethod files:resolve ((profile nyxt:nyxt-profile) (file nyxt/mode/bookmark:bookmarks-file))
  "Reroute the bookmarks to the config directory."
  #p"~/.config/nyxt/bookmarks.lisp")

(define-configuration :reduce-tracking-mode
  ((query-tracking-parameters
    (append '("utm_source" "utm_medium" "utm_campaign" "utm_term" "utm_content")
            %slot-value%)
    :doc "This is to strip UTM-parameters off all the links.
Upstream Nyxt doesn't have it because it may break some websites.")
   (preferred-user-agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36"
    :doc "Mimic Chrome on MacOS.")))

(unless nyxt::*run-from-repl-p*
  (define-configuration :browser
    "Enable Nyxt-internal debugging, but only in binary mode and after startup if done.
There are conditions raised at startup, and I don't want to catch
those, hanging my Nyxt)."
    ((after-startup-hook (hooks:add-hook %slot-value% #'toggle-debug-on-error)))))

;; (defun request-log (request-data)
;;   (log:debug "~:@(~a~) ~a (~@[~*toplevel~]~@[~*resource~]) ~{~&~a~}"
;;              (http-method request-data) (url request-data)
;;              (toplevel-p request-data) (resource-p request-data)
;;              (request-headers request-data))
;;   request-data)

;; (define-configuration :web-buffer
;;   "Request debugging, clutters the shell real fast."
;;   ((request-resource-hook
;;     (hooks:add-hook %slot-value% #'request-log))))
