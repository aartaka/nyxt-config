(in-package #:nyxt-user)

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
