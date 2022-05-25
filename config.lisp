(in-package #:nyxt-user)

(defun nyxt-init-file (filename)
  (nyxt-config-file filename))

(load (nyxt-config-file "init.lisp"))
