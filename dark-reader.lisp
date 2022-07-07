(in-package #:nyxt-user)

(define-configuration nx-dark-reader:dark-reader-mode
  ((nxdr:selection-color "#CD5C5C")
   (nxdr:background-color "black")
   (nxdr:text-color "white")
   (nxdr:sepia 0)
   (nxdr:grayscale 40)
   (nxdr:contrast 100)
   (nxdr:brightness 100)))

(push 'nx-dark-reader:dark-reader-mode *web-buffer-modes*)
