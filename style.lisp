(in-package #:nyxt-user)

;; This automatically darkens WebKit-native interfaces and sends the
;; "prefers-color-scheme: dark" to all the supporting websites.
(setf (uiop:getenv "GTK_THEME") "Adwaita:dark")

(define-configuration browser
  "Configuring my reddish theme."
  ((theme (apply
           #'make-instance
           'theme:theme
           :background-color "black"
           #+nyxt-4 :action-color
           #-nyxt-4 :accent-color "#CD5C5C"
           :warning-color "#CEFF00"
           :primary-color "rgb(170, 170, 170)"
           :secondary-color "rgb(100, 100, 100)"
           ;; #-nyxt-4
           nil
           ;; #+nyxt-4
           (list
            :text-color "#FFF4F3"
            :contrast-text-color "#250000"
            :highlight-color "red"
            :success-color "#2D9402"
            :codeblock-color "#600101")))))

(define-configuration :dark-mode
  "Dark-mode is a simple mode for simple HTML pages to color those in a darker palette.

I don't like the default gray-ish colors, though. Thus, I'm overriding
those to be a bit more laconia-like.

I'm not using this mode, though: I have nx-dark-reader."
  ((style
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
        :color ,theme:primary "!important")))))
