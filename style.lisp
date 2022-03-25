(in-package #:nyxt-user)

;; This automatically darkens WebKit-native interfaces and sends the
;; "prefers-color-scheme: dark" to all the supporting websites.
(setf (uiop:getenv "GTK_THEME") "Adwaita:dark")

;;;; My color preferences weren't satisfied by any Emacs theme, so I
;;;; wrote mine: Laconia (https://github.com/aartaka/laconia). This
;;;; file is simply a translation of Laconia colors to Nyxt interface.
;;;;
;;;; This only works on the versions of Nyxt after 3.0. For the
;;;; backwards-compatible solution, see previous versions of this
;;;; file.
(define-configuration browser
  ((theme (make-instance
           'theme:theme
           :dark-p t
           :background-color "black"
           :text-color "white"
           :accent-color "#CD5C5C"
           :primary-color "rgb(170, 170, 170)"
           :secondary-color "rgb(140, 140, 140)"
           :tertiary-color "rgb(115, 115, 115)"
           :quaternary-color "rgb(85, 85, 85)"))))

;;; Dark-mode is a simple mode for simple HTML pages to color those in
;;; a darker palette. I don't like the default gray-ish colors,
;;; though. Thus, I'm overriding those to be a bit more laconia-like.
(define-configuration nyxt/style-mode:dark-mode
  ((style #.(cl-css:css
             '((*
                :background-color "black !important"
                :background-image "none !important"
                :color "white")
               (a
                :background-color "black !important"
                :background-image "none !important"
                :color "#556B2F !important"))))))
