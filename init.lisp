(in-package #:nyxt-user)

(load-after-system :slynk (nyxt-init-file "slynk.lisp"))
(load (nyxt-init-file "passwd.lisp"))

(define-configuration browser
  ((session-restore-prompt :always-ask)))

(define-configuration window
  ((message-buffer-style
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

(defun wordnet (&key
                  ;; TODO: Support "Hide all" and "Show-all" args?
                  (shortcut "wordnet")
                  (examples t examples-supplied-p)
                  (glosses t glosses-supplied-p)
                  (freqs nil freqs-supplied-p)
                  (db-locations nil db-locations-supplied-p)
                  (lexical-file-info nil lexical-file-info-supplied-p)
                  (lexical-file-nums nil lexical-file-nums-supplied-p)
                  (sense-keys nil sense-keys-supplied-p)
                  (sense-nums nil sense-nums-supplied-p))
  "Return the configured `nyxt:search-engine' for WordNet.

To use it, disable force-https-mode for wordnetweb.princeton.edu or
add auto-mode rule that will manage that for you!

Arguments mean:
SHORTCUT -- the shortcut you need to input to use this search engine. Set to \"wordnet\" by default.
EXAMPLES -- Show example sentences. True by default.
GLOSSES -- Show definitions. True by default.
FREQS -- Show word frequency counts. False by default.
DB-LOCATIONS -- Show WordNet database locations for this word. False by default.
LEXICAL-FILE-INFO -- Show lexical file word belongs to. False by default.
LEXICAL-FILE-NUMS -- Show number of the word in the lexical file. False by default.
SENSE-KEYS -- Show symbols for senses of the word. False by default.
SENSE-NUMS -- Show sense numbers. False by default.

A sensible non-default example:
\(wordnet :shortcut \"wn\"
         :freqs t
         :sense-nums t
         :examples nil)

This search engine, invokable with \"wn\", will show:
- NO example sentences,
- glosses,
- frequency counts,
- sense-numbers."
  (make-instance 'search-engine
                 :shortcut shortcut
                 :fallback-url "http://wordnetweb.princeton.edu/perl/webwn"
                 :search-url (concatenate
                              'string
                              "http://wordnetweb.princeton.edu/perl/webwn?s=~a"
                              ;; Quite a convoluted control string it is, isn't it?
                              ;; What it means is basically "For each entry in alist,
                              ;; if the first argument (supplied-p) is true,
                              ;; then format remaining ones into "&oX=(|1)"."
                              (format nil "~:{~@[&~*~a=~:[~;1~]~]~}"
                                      (list (list examples-supplied-p          "o0" examples)
                                            (list glosses-supplied-p           "o1" glosses)
                                            (list freqs-supplied-p             "02" freqs )
                                            (list db-locations-supplied-p      "o3" db-locations)
                                            (list lexical-file-info-supplied-p "o4" lexical-file-info)
                                            (list lexical-file-nums-supplied-p "o5" lexical-file-nums)
                                            (list sense-keys-supplied-p        "o6" sense-keys)
                                            (list sense-nums-supplied-p        "o7" sense-nums))))))

(define-configuration buffer
  ((default-modes `(emacs-mode ,@%slot-default))
   (conservative-word-move t)
   ;; QWERTY home row.
   (hints-alphabet "DSJKHLFAGNMXCWEIO")
   (override-map (keymap:define-key %slot-default
                   "C-c p c" 'copy-password
                   "C-c p s" 'save-new-password))
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
                         (wordnet :shortcut "wn"
                                  :freqs t
                                  :sense-nums t)
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
