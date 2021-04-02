(in-package #:nyxt-user)

(define-configuration password:keepassxc-interface
  ((password:password-file "/home/aartaka/Documents/p.kdbx")))

(define-configuration buffer
  ((password-interface (make-instance 'password:user-keepassxc-interface))))

(define-command setup-keepassxc (&optional (interface (nyxt::password-interface (current-buffer))))
  "Input all the necessary values into the `password::keepassxc-interface' INTERFACE.
Prompt for `password::password-file' once and only in case it's not set.
Prompt for `password::master-password' until the database is unlocked.
Be wary that completion is not perfect ¯\_(ツ)_/¯"
  (loop :initially (unless (password::password-file interface)
                     (setf (password::password-file interface)
                           (first (prompt :sources (list (make-instance 'prompter:raw-source
                                                                        :name "Password file"))))))
        :until (password:password-correct-p interface)
        :do (setf (password::master-password interface)
                  (first (prompt :sources (list (make-instance 'prompter:raw-source
                                                               :name "Password"))
                                 :invisible-input-p t)))))
