(in-package #:nyxt-user)

(defmethod initialize-instance :after ((interface password:keepassxc-interface) &key &allow-other-keys)
  "I use KeePassXC, and this simply sets the location of the password files."
  (setf (password:password-file interface) "/home/aartaka/Documents/p.kdbx"))

(define-configuration :password-mode
  "This is to emphasize that I use KeePassXC.
Nyxt is (was?) not always smart enough to guess that."
  ((password-interface (make-instance 'password:keepassxc-interface))))

(define-configuration :buffer
  ((default-modes (append `(:password-mode) %slot-value%))))

