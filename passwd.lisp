(in-package #:nyxt-user)

(define-configuration password:keepassxc-interface
  ((password:password-file "/home/aartaka/Documents/p.kdbx")))

(define-configuration buffer
  ((password-interface (make-instance 'password:user-keepassxc-interface))))
