(in-package #:nyxt-user)

;;; I use KeePassXC, and this simply sets the location of the password
;;; files.
(define-configuration password:keepassxc-interface
  ((password:password-file "/home/aartaka/Documents/p.kdbx")))

;; This is to emphasize that I use KeePassXC, as Nyxt is not always
;; smart enough to guess that.
(define-configuration buffer
  ((password-interface (make-instance 'password:user-keepassxc-interface))))
