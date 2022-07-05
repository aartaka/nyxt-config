(in-package #:nyxt-user)

(setf *default-pathname-defaults* (uiop:pathname-directory-pathname (files:expand *config-file*)))

(load "init")
