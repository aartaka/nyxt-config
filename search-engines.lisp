(in-package #:nyxt-user)

(defvar *duckduckgo-keywords*
  '(:theme :dark
    :help-improve-duckduckgo nil
    :homepage-privacy-tips nil
    :privacy-newsletter nil
    :newsletter-reminders nil
    :install-reminders nil
    :install-duckduckgo nil
    :units-of-measure :metric
    :keyboard-shortcuts t
    :advertisements nil
    :open-in-new-tab nil
    :infinite-scroll t
    :safe-search :off
    :font-size :medium
    :header-behavior :off
    :font :helvetica
    :background-color "000000"
    :center-alignment t))

(define-configuration buffer
  ((search-engines (list
                    (make-instance 'search-engine
                                   :shortcut "whois"
                                   :search-url "https://whoisrequest.com/whois/~a"
                                   :fallback-url "https://whoisrequest.com/")
                    (make-instance 'search-engine
                                   :shortcut "ftp"
                                   :search-url "http://www.freewareweb.com/cgi-bin/ftpsearch.pl?q=~a"
                                   :fallback-url "http://www.freewareweb.com/ftpsearch.shtml")
                    (engines:google :shortcut "gmaps"
                                    :object :maps)
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
                                   :shortcut "y"
                                   :search-url "https://yandex.com/search/?text=~a"
                                   :fallback-url "https://yandex.com/search/")
                    (engines:wordnet :shortcut "wn"
                                     :show-word-frequencies t)
                    (engines:google :shortcut "g"
                                    :safe-search nil)
                    (apply #'engines:duckduckgo-images
                           :shortcut "di" *duckduckgo-keywords*)
                    (apply #'engines:duckduckgo
                           :shortcut "d" *duckduckgo-keywords*)))))

(define-configuration engines:search-engines-mode
  ((engines::search-engine (apply #'engines:duckduckgo *duckduckgo-keywords*))
   (engines::image-search-engine (apply #'engines:duckduckgo-images *duckduckgo-keywords*))
   (glyph "σ")))

(define-configuration web-buffer
  ((default-modes `(engines:search-engines-mode ,@%slot-default%))))
