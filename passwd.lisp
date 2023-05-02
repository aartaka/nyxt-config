(in-package #:nyxt-user)

;;; I use KeePassXC, and this simply sets the location of the password
;;; files.
#+nyxt-2
(define-configuration password:keepassxc-interface
  ((password:password-file "/home/aartaka/Documents/p.kdbx")))
#+nyxt-3
(defmethod initialize-instance :after ((interface password:keepassxc-interface) &key &allow-other-keys)
  (setf (password:password-file interface) "/home/aartaka/Documents/p.kdbx"))

;; This is to emphasize that I use KeePassXC, as Nyxt is not always
;; smart enough to guess that.
#+nyxt-2
(define-configuration buffer
  ((password-interface (make-instance 'password:user-keepassxc-interface))))
#+nyxt-3
(define-configuration :password-mode
  ((password-interface (make-instance 'password:keepassxc-interface))))
#+nyxt-3
(define-configuration buffer
  ((default-modes (append `(:password-mode) %slot-value%))))

