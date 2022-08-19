(in-package #:nyxt-user)

;;; Adding YouTube -> Invidious, Instagram -> Bibliogram handlers.
;;; Uses symbols as handlers, which is a new cool syntax.
;;; Use the example from the manual if you are on 2.x.

(define-configuration web-buffer
  ((request-resource-hook
    (progn
      (hooks:add-hook %slot-value% 'nx-freestance-handler:invidious-handler)
      (hooks:add-hook %slot-value% 'nx-freestance-handler:bibliogram-handler)))))
