(in-package #:nyxt-user)

(define-command-global eval-expression ()
  "Prompt for the expression and evaluate it, echoing result to the `message-area'."
  (let ((expression-string
          ;; Read an arbitrary expression. No error checking, though.
          (first (prompt :prompt "Expression to evaluate"
                         :sources (list (make-instance 'prompter:raw-source))))))
    ;; Message the evaluation result to the message-area down below.
    (echo "~S" (eval (read-from-string expression-string)))))

#+nyxt-3
(nyxt::define-panel-global hsplit (&key (buffer (id (current-buffer))))
    (panel "Duplicate panel" :right)
  "Duplicate the current buffer URL in the panel buffer on the right.

A poor man's hsplit :)"
  (progn
    (ffi-window-set-panel-buffer-width (current-window) panel 750)
    (run-thread "URL loader"
      (buffer-load (url (nyxt::buffers-get buffer)) :buffer panel))
    ""))

#+nyxt-3
(define-command-global close-all-panels ()
  "Close all the panel buffers there are."
  (when (panel-buffers-right (current-window))
    (delete-panel-buffer :window (current-window) :panels (panel-buffers-right (current-window))))
  (when (panel-buffers-left (current-window))
    (delete-panel-buffer :window (current-window) :panels (panel-buffers-left (current-window)))))

#+nyxt-3
(define-command-global hsplit ()
  "Based on `hsplit-panel' above.
Cleans the existing panel buffers before doing hsplit."
  (close-all-panels)
  (hsplit-panel))
