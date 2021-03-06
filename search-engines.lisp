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
                                   (let ((installed-packages
                                           (str:split nyxt::+newline+
                                                      (ignore-errors
                                                       (uiop:run-program
                                                        "go list all"
                                                        :output '(:string :stripped t))))))
                                     (lambda (input)
                                       (sort
                                        (serapeum:filter (alexandria:curry #'str:containsp input)
                                                         installed-packages)
                                        #'> :key (alexandria:curry
                                                  #'prompter::score-suggestion-string input)))))
                    (engines:wikipedia)
                    (make-instance 'search-engine
                                   :shortcut "yi"
                                   :search-url "https://yandex.ru/images/search?text=~a"
                                   :fallback-url (quri:uri "https://yandex.ru/images/"))
                    (make-instance 'search-engine
                                   :shortcut "y"
                                   :search-url "https://yandex.com/search/?text=~a"
                                   :fallback-url (quri:uri "https://yandex.com/search/"))
                    (engines:wordnet :shortcut "wn"
                                     :show-word-frequencies t)
                    (engines:google :shortcut "g"
                                    :safe-search nil)
                    (engines:startpage
                     :shortcut "sp"
                     :family-filter nil
                     :settings-string "806f879950cd466952c5379f2307693b30b87ef2da8e631a6b9c190cf0251f48de50be0202b48b0fa76beefe9b7427b693baeb77c4d24660dc6799469afc24785a974987168e79ce297ca202ad28")
                    (apply #'engines:duckduckgo-images
                           :shortcut "i" *duckduckgo-keywords*)
                    (engines:duckduckgo-html-only :shortcut "dho")
                    (apply #'engines:duckduckgo
                           :shortcut "d" *duckduckgo-keywords*)))))

;; (define-configuration engines:search-engines-mode
;;   ((engines::search-engine (apply #'engines:duckduckgo *duckduckgo-keywords*))
;;    (engines::image-search-engine (apply #'engines:duckduckgo-images *duckduckgo-keywords*))
;;    (glyph "σ")))

;; (define-configuration web-buffer
;;   ((default-modes `(engines:search-engines-mode ,@%slot-default%))))
