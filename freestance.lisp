(in-package #:nyxt-user)

(define-configuration :web-buffer
  "Adding YouTube -> Invidious handler."
  ((request-resource-hook
    (hooks:add-hook %slot-value% 'nx-freestance-handler:invidious-handler))))
