(in-package #:nyxt-user)

(define-configuration window
  ((message-buffer-style
    (str:concat
     %slot-default
     (cl-css:css
      '((body
         :background-color "black"
         :color "white")))))))

(define-configuration prompt-buffer
  ((style (str:concat
           %slot-default
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
     %slot-default
     (cl-css:css
      '((title
         :color "#CD5C5C")
        (h1
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
  ((nyxt/history-tree-mode:style
    (str:concat
     %slot-default
     (cl-css:css
      '((title
         :background-color "#CD5C5C"
         :color "black"
         :padding 10)
        (h1
         :background-color "#CD5C5C"
         :color "black"
         :padding 10)
        (body
         :background-color "black"
         :color "lightgray")
        (hr
         :color "darkgray")
        (a
         :color "#556B2F")))))))
