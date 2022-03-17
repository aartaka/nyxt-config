(in-package #:nyxt-user)

;;; Adding YouTube -> Invidious, Instagram -> Bibliogram handlers.
;;; Uses symbols as handlers, which is a new cool syntax.
;;; Use the example from the manual if you are on 2.x.

(setf *request-resource-handlers*
      (append *request-resource-handlers*
              (list 'nx-freestance-handler:invidious-handler 'nx-freestance-handler:bibliogram-handler)))
