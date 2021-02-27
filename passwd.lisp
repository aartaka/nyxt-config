(in-package #:nyxt-user)

(define-configuration password:keepassxc-interface
  ((password:password-file "/home/aartaka/Documents/p.kdbx")))

(define-command setup-keepassxc (&optional (interface (nyxt::password-interface (current-buffer))))
  "Input all the necessary values into the `password::keepassxc-interface' INTERFACE.
Prompt for `password::password-file' once and only in case it's not set.
Prompt for `password::master-password' until the database is unlocked.
Be wary that completion is not perfect ¯\_(ツ)_/¯"
  (loop :initially (unless (password::password-file interface)
                     (setf (password::password-file interface)
                           (prompt-minibuffer
                            :input-prompt "Password file"
                            :input-buffer (namestring (uiop:getcwd)))))
        :until (password:password-correct-p interface)
        :do (setf (password::master-password interface)
                  (prompt-minibuffer :input-prompt "Master pass" :invisible-input-p t))))
