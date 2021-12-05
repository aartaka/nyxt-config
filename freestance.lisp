(in-package #:nyxt-user)

;;; Adding YouTube -> Invidious, Instagram -> Bibliogram handlers.
(define-configuration web-buffer
    ((request-resource-hook
      (reduce #'hooks:add-hook
              (mapcar #'make-handler-resource
                      (list #'nx-freestance-handler:invidious-handler #'nx-freestance-handler:bibliogram-handler))
              :initial-value %slot-default%))))
