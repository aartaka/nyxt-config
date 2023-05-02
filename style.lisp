(in-package #:nyxt-user)

;; This automatically darkens WebKit-native interfaces and sends the
;; "prefers-color-scheme: dark" to all the supporting websites.
(setf (uiop:getenv "GTK_THEME") "Adwaita:dark")

;; My color preferences weren't satisfied by any Emacs theme, so I
;; wrote mine: Laconia (https://github.com/aartaka/laconia). This
;; file is simply a translation of Laconia colors to Nyxt interface.
;;
;; This only works on the versions of Nyxt after 3.0. For the
;; backwards-compatible solution, see previous versions of this
;; file.
(define-configuration browser
  ((theme (make-instance
           'theme:theme
           :dark-p t
           :background-color "black"
           :on-background-color "white"
           :accent-color "#CD5C5C"
           :primary-color "rgb(170, 170, 170)"
           :on-primary-color "black"
           :secondary-color "rgb(100, 100, 100)"
           :on-secondary-color "white"))))

;;; Dark-mode is a simple mode for simple HTML pages to color those in
;;; a darker palette. I don't like the default gray-ish colors,
;;; though. Thus, I'm overriding those to be a bit more laconia-like.
(define-configuration :dark-mode
  ((style
    #+(and nyxt-3 (not (or nyxt-2 nyxt-3-pre-release-1)))
    (theme:themed-css (theme *browser*)
      `(*
        :background-color ,(if (theme:dark-p theme:theme)
                               theme:background
                               theme:on-background)
        "!important"
        :background-image none "!important"
        :color ,(if (theme:dark-p theme:theme)
                    theme:on-background
                    theme:background)
        "!important")
      `(a
        :background-color ,(if (theme:dark-p theme:theme)
                               theme:background
                               theme:on-background)
        "!important"
        :background-image none "!important"
        :color ,theme:primary "!important"))
    #+(or nyxt-2 nyxt-3-pre-release-1)
    (theme:themed-css (theme *browser*)
      (*
       :background-color (str:concat
                          (if (theme:dark-p theme:theme)
                              theme:background
                              theme:on-background)
                          " !important")
       :background-image "none !important"
       :color (str:concat
               (if (theme:dark-p theme:theme)
                   theme:on-background
                   theme:background)
               " !important"))
      (a
       :background-color (str:concat
                          (if (theme:dark-p theme:theme)
                              theme:background
                              theme:on-background)
                          " !important")
       :background-image "none !important"
       :color (str:concat theme:primary " !important"))))))
