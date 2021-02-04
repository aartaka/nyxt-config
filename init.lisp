(in-package #:nyxt-user)

(load-after-system :slynk (nyxt-init-file "slynk.lisp"))

(define-configuration browser
  ((session-restore-prompt :always-ask)))

(push #'password:make-keepassxc-interface password:interface-list)

(define-command setup-keepassxc (&optional (interface (nyxt::password-interface *browser*)))
  "Input all the necessary values into the `password::keepassxc-interface' INTERFACE.
Prompt for `password::password-file' once only.
Prompt for `password::master-password' until the database is unlocked.
Be wary that completion is not perfect ¯\_(ツ)_/¯"
  (loop :initially (setf (password::password-file interface)
                         (prompt-minibuffer
                          :input-prompt "Password file"
                          :input-buffer (namestring (uiop:getcwd))))
        :until (ignore-errors (password:list-passwords interface))
        :do (setf (password::master-password interface)
                  (prompt-minibuffer :input-prompt "Master pass" :invisible-input-p t))))

(defun format-short-status-modes (&optional (buffer (current-buffer)))
  "A shorter version of built-in `format-status-modes'.

Main difference: the modes I personally use often are replaced
with (mostly) Greek letters."
  (str:replace-using
   '("-mode" ""
     "base" ""
     "emacs" "ξ" ; Xi looks like Emacs logo...
     "force-https" "ϕ"
     "auto" "α"
     "blocker" "β"
     "proxy" "π"
     "reduce-tracking" "τ"
     "certificate-exception" "χ"
     "style" "σ"
     "web" "ω"
     "help" "?")
   (format nil "~{~a~^ ~}"
           (mapcar (alexandria:compose #'str:downcase #'mode-name)
                   (modes buffer)))))

(defun format-short-status-load-status (&optional (buffer (current-buffer)))
  "A shorter version of built-in `format-status-load-status'.
Glyphs are used to reflect the `load-status' other than :finished."
  (when (web-buffer-p buffer)
    (case (slot-value buffer 'nyxt::load-status)
      (:unloaded "∅")
      (:loading "∞")
      (:finished ""))))

(defun format-short-status-url (&optional (buffer (current-buffer)))
  "A shorter version of built-in `format-status-url'.
Strips all the obvious decorations (HTTPS scheme, WWW prefix, trailing
slashes) off the URL."
  (markup:markup
   (:a :class "button"
       :href (lisp-url '(nyxt:set-url-from-current-url))
       (str:concat
        (format-short-status-load-status buffer)
        (format nil " ~a — ~a"
                (ppcre:regex-replace-all
                 "(https://|www\\.|/$)"
                 (object-display (url buffer))
                 "")
                (title buffer))))))

(defun short-format-status (window)
  "An alternative version of built-in `format-status'.
Most sub-functions are replaced with shorter counterparts."
  (let ((buffer (current-buffer window)))
    (markup:markup
     (:div :id "container"
           (:div :id "controls" (markup:raw ""))
           (:div :class "arrow arrow-right"
                 :style "background-color:rgb(80,80,80)" "")
           (:div :id "url" (markup:raw (format-short-status-url buffer)))
           (:div :class "arrow arrow-right"
                 :style "background-color:rgb(120,120,120)" "")
           (:div :id "tabs" (markup:raw (format-status-tabs)))
           (:div :class "arrow arrow-left"
                 :style "background-color:rgb(120,120,120)" "")
           (:div :id "modes" (format-short-status-modes buffer))))))

(define-configuration window
  ((status-formatter #'short-format-status)
   (message-buffer-style
    (str:concat
     %slot-default
     (cl-css:css
      '((body
         :background-color "black"
         :color "white")))))))

(define-configuration minibuffer
  ((style
    (str:concat
     %slot-default
     (cl-css:css
      '((body
         :background-color "black"
         :color "#808080")))))))

(define-configuration buffer
  ((default-modes `(emacs-mode ,@%slot-default))
   (conservative-word-move t)
   ;; QWERTY home row.
   (hints-alphabet "DSJKHLFAGNMXCWEIO")
   (search-engines (list (make-instance 'search-engine
                                        :shortcut "whois"
                                        :search-url "https://whoisrequest.com/whois/~a"
                                        :fallback-url "https://whoisrequest.com/")
                         (make-instance 'search-engine
                                        :shortcut "ftp"
                                        :search-url "http://www.freewareweb.com/cgi-bin/ftpsearch.pl?q=~a"
                                        :fallback-url "http://www.freewareweb.com/ftpsearch.shtml")
                         (make-instance 'search-engine
                                        :shortcut "gmaps"
                                        :search-url "https://www.google.pl/maps/search/~a"
                                        :fallback-url "https://www.google.pl/maps/search/")
                         (make-instance 'search-engine
                                        :shortcut "osm"
                                        :search-url "https://www.openstreetmap.org/search?query=~a"
                                        :fallback-url "https://www.openstreetmap.org/")
                         (make-instance 'search-engine
                                        :shortcut "wikiwikiweb"
                                        :search-url "https://proxy.c2.com/cgi/fullSearch?search=~a"
                                        :fallback-url "http://wiki.c2.com/?FindPage")
                         (make-instance 'search-engine
                                        :shortcut "wiki"
                                        :search-url "https://en.wikipedia.org/w/index.php?search=~a"
                                        :fallback-url "https://en.wikipedia.org/")
                         (make-instance 'search-engine
                                        :shortcut "yimg"
                                        :search-url "https://yandex.ru/images/search?text=~a"
                                        :fallback-url "https://yandex.ru/images/")
                         (make-instance 'search-engine
                                        :shortcut "wn"
                                        ;; As this is an HTTP-only URL, you also need to add
                                        ;; an auto-mode rule to not enable force-https-mode there.
                                        :search-url (str:concat
                                                     "http://wordnetweb.princeton.edu/perl/webwn?s=~a&"
                                                     (str:join "&"
                                                               '("o0=1"    ; Show Example sentences
                                                                 "o1=1"    ; Show Glosses (explanations)
                                                                 "02=1"    ; Show Frequency counts
                                                                 ;; "o3="     ; Hide Database Locations
                                                                 ;; "o4="     ; Hide Lexical File Info
                                                                 ;; "o5="     ; Hide Lexical File Numbers
                                                                 ;; "o6="     ; Hide Sense Keys
                                                                 ;; "o7="     ; Hide Sense Numbers
                                                                 ))
                                                     )
                                        :fallback-url "http://wordnetweb.princeton.edu/perl/webwn")
                         (make-instance 'search-engine
                                        :shortcut "y"
                                        :search-url "https://yandex.com/search/?text=~a"
                                        :fallback-url "https://yandex.com/search/")
                         (make-instance 'search-engine
                                        :shortcut "g"
                                        :search-url "https://google.com/search?q=~a&safe=images"
                                        :fallback-url "https://google.com/search/")
                         (make-instance 'search-engine
                                        :shortcut "d"
                                        :search-url "https://duckduckgo.com/?q=~a&kae=d&kau=-1&kao=-1&kaq=-1&kap=-1&kax=-1&kak=-1&kaj=m&kk=1&k1=-1&kn=-1&kav=1&kp=-2&ks=m&ko=-1&kt=h&k7=000000&km=m"
                                        :fallback-url "https://duckduckgo.com/")))))

(define-configuration web-buffer
  ((default-modes `(emacs-mode auto-mode blocker-mode force-https-mode
                               ,@%slot-default))))

(define-configuration internal-buffer
  ((style
    (str:concat
     %slot-default
     (cl-css:css
      '((body
         :background-color "black"
         :color "lightgray")
        (hr
         :color "darkgray")
        (.button
         :color "#333333")))))))

(define-configuration nyxt/auto-mode:auto-mode
  ((nyxt/auto-mode:prompt-on-mode-toggle t)))
