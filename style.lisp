(in-package #:nyxt-user)

(define-configuration window
  ((message-buffer-style
    (str:concat
     %slot-default%
     (cl-css:css
      '((body
         :background-color "black"
         :color "white")))))))

(define-configuration prompt-buffer
  ((style (str:concat
           %slot-default%
           (cl-css:css
            '((body
               :background-color "black"
               :color "white")
              ("#prompt-area"
               :background-color "black")
              ("#input"
               :background-color "white")
              (".source-name"
               :color "black"
               :background-color "#556B2F")
              (".source-content"
               :background-color "black")
              (".source-content th"
               :border "1px solid #556B2F"
               :background-color "black")
              ("#selection"
               :background-color "#CD5C5C"
               :color "black")
              (.marked :background-color "#8B3A3A"
                       :font-weight "bold"
                       :color "white")
              (.selected :background-color "black"
                         :color "white")))))))

(define-configuration internal-buffer
  ((style
    (str:concat
     %slot-default%
     (cl-css:css
      '((title
         :color "#CD5C5C")
        (body
         :background-color "black"
         :color "lightgray")
        (hr
         :color "darkgray")
        (a
         :color "#556B2F")
        (.button
         :color "lightgray"
         :background-color "#556B2F")))))))

(define-configuration nyxt/history-tree-mode:history-tree-mode
  ((nyxt/history-tree-mode::style
    (str:concat
     %slot-default%
     (cl-css:css
      '((body
         :background-color "black"
         :color "lightgray")
        (hr
         :color "darkgray")
        (a
         :color "#556B2F")
        ("ul li::before"
         :background-color "white")
        ("ul li::after"
         :background-color "white")
        ("ul li:only-child::before"
         :background-color "white")))))))

(define-configuration nyxt/web-mode:web-mode
  ((nyxt/web-mode:highlighted-box-style
    (cl-css:css
     '((".nyxt-hint.nyxt-highlight-hint"
        :background "#CD5C5C")))
    :documentation "The style of highlighted boxes, e.g. link hints.")))

(define-configuration status-buffer
  ((style (str:concat
           %slot-default%
           (cl-css:css
            '(("#controls"
               :border-top "1px solid white")
              ("#url"
               :background-color "black"
               :color "white"
               :border-top "1px solid white")
              ("#modes"
               :background-color "black"
               :border-top "1px solid white")
              ("#tabs"
               :background-color "#CD5C5C"
               :color "black"
               :border-top "1px solid white")))))))

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
