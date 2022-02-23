(in-package #:nyxt-user)

(define-configuration nx-dark-reader:dark-reader-mode
  ((nxdr:selection-color "#CD5C5C")
   (nxdr:background-color "black")
   (nxdr:text-color "white")))

(push 'nx-dark-reader:dark-reader-mode *web-buffer-modes*)
