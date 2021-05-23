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
    :header-behavior :on-fixed
    :font :helvetica
    :background-color "000000"
    :center-alignment t))

(define-configuration buffer
  ((search-engines (list
                    (engines:google :shortcut "gmaps"
                                    :object :maps)
                    (make-instance 'search-engine
                                   :shortcut "osm"
                                   :search-url "https://www.openstreetmap.org/search?query=~a"
                                   :fallback-url "https://www.openstreetmap.org/")
                    (make-instance 'search-engine
                                   :shortcut "golang"
                                   :search-url "https://golang.org/pkg/~a/"
                                   :fallback-url (quri:uri "https://golang.org/pkg/")
                                   :completion-function
                                   (lambda (input)
                                     (let ((installed-packages
                                             (str:split nyxt::+newline+
                                                        (uiop:run-program
                                                         "go list all"
                                                         :output '(:string :stripped t)))))
                                       (sort
                                        (serapeum:filter
                                         #'(lambda (package)
                                             (str:containsp input package :ignore-case t))
                                         installed-packages)
                                        #'(lambda (package1 package2)
                                            (> (prompter::score-suggestion-string input package1)
                                               (prompter::score-suggestion-string input package2)))))))
                    (make-instance 'search-engine
                                   :shortcut "wiki"
                                   :search-url "https://en.wikipedia.org/w/index.php?search=~a"
                                   :fallback-url "https://en.wikipedia.org/")
                    (make-instance 'search-engine
                                   :shortcut "yi"
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
                           :shortcut "i" *duckduckgo-keywords*)
                    (apply #'engines:duckduckgo
                           :shortcut "d" *duckduckgo-keywords*)))))

(define-configuration engines:search-engines-mode
  ((engines::search-engine (apply #'engines:duckduckgo *duckduckgo-keywords*))
   (engines::image-search-engine (apply #'engines:duckduckgo-images *duckduckgo-keywords*))
   (glyph "σ")))

(define-configuration web-buffer
  ((default-modes `(engines:search-engines-mode ,@%slot-default%))))
