(in-package #:nyxt-user)

;; Adding ALL (Twitter, Reddit, YouTube) freestance handlers. I'll regret it.
(define-configuration web-buffer
  ((request-resource-hook
    (reduce #'hooks:add-hook
            (mapcar #'make-handler-resource
		            nx-freestance-handler:*freestance-handlers*)
            :initial-value %slot-default%))))
