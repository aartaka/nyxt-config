(in-package #:nyxt-user)

#+nyxt-3
(define-panel-command hsplit-internal (&key (url (quri:render-uri (url (current-buffer)))))
    (panel "*Duplicate panel*" :right)
  "Duplicate the current buffer URL in the panel buffer on the right.

A poor man's hsplit :)"
  (setf
   #-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
   (ffi-window-panel-buffer-width (current-window) panel)
   #+(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
   (ffi-width panel)
   550)
  (run-thread "URL loader"
    (sleep 0.3)
    (buffer-load (quri:uri url) :buffer panel))
  "")

#-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
(define-command-global close-all-panels ()
  "Close all the panel buffers there are."
  (alexandria:when-let ((panels (#-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
                                 panel-buffers-right
                                 #+(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
                                 nyxt/renderer/gtk::panel-buffers-right
                                 (current-window))))
    (delete-panel-buffer :window (current-window) :panels panels))
  (alexandria:when-let ((panels (#-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
                                 panel-buffers-left
                                 #+(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
                                 nyxt/renderer/gtk::panel-buffers-left
                                 (current-window))))
    (delete-panel-buffer :window (current-window) :panels panels)))

#+nyxt-3
(define-command-global hsplit ()
  "Based on `hsplit-internal' above."
  (if (#-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
       panel-buffers-right
       #+(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
       nyxt/renderer/gtk::panel-buffers-right
       (current-window))
      #-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
      (close-all-panels)
      #+(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
      (delete-all-panel-buffers (current-window))
      (hsplit-internal)))
