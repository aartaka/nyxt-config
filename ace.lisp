(in-package #:nyxt-user)

;;;; This is a configuration for the Ace editor Nyxt integration
;;;; (https://github.com/atlas-engineer/nx-ace). I'm not using it
;;;; much, though.

(define-configuration editor-buffer
  ((default-modes `(nyxt/editor-mode:ace-mode nyxt::base-mode))))
