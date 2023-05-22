(in-package #:nyxt-user)

(define-panel-command hsplit-internal (&key (url (quri:render-uri (url (current-buffer)))))
    (panel "*Duplicate panel*" :right)
  "Duplicate the current buffer URL in the panel buffer on the right.

A poor man's hsplit :)"
  (setf (ffi-width panel) 550)
  (run-thread "URL loader"
    (sleep 0.3)
    (buffer-load (quri:uri url) :buffer panel))
  "")

(define-command-global close-all-panels ()
  "Close all the panel buffers there are."
  (alexandria:when-let ((panels (nyxt/renderer/gtk::panel-buffers-right (current-window))))
    (delete-panel-buffer :window (current-window) :panels panels))
  (alexandria:when-let ((panels (nyxt/renderer/gtk::panel-buffers-left (current-window))))
    (delete-panel-buffer :window (current-window) :panels panels)))

(define-command-global hsplit ()
  "Based on `hsplit-internal' above."
  (if (nyxt/renderer/gtk::panel-buffers-right (current-window))
      (delete-all-panel-buffers (current-window))
      (hsplit-internal)))
