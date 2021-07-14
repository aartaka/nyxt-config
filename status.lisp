(in-package #:nyxt-user)

(define-configuration status-buffer
  ((glyph-mode-presentation-p t)))

(define-configuration nyxt/force-https-mode:force-https-mode ((glyph "ϕ")))
(define-configuration nyxt/blocker-mode:blocker-mode ((glyph "β")))
(define-configuration nyxt/proxy-mode:proxy-mode ((glyph "π")))
(define-configuration nyxt/reduce-tracking-mode:reduce-tracking-mode
  ((glyph "τ")))
(define-configuration nyxt/certificate-exception-mode:certificate-exception-mode
  ((glyph "χ")))
(define-configuration nyxt/style-mode:style-mode ((glyph "ϕ")))
(define-configuration nyxt/help-mode:help-mode ((glyph "?")))

(defun laconic-format-status-load-status (buffer)
  (if (web-buffer-p buffer)
      (case (slot-value buffer 'nyxt::load-status)
        (:unloaded "∅")
        (:loading "∞")
        (:finished ""))
      ""))

(defun laconic-format-status-url (buffer)
  (markup:markup
   (:span
    (format nil "~a ~a"
            (laconic-format-status-load-status buffer)
            (ppcre:regex-replace-all
             "(https://|www\\.|/$)"
             (render-url (url buffer))
             "")))))

(defun laconic-format-status-modes (buffer window)
  (markup:raw
   (format-status-modes buffer window)
   " | "
   (format nil "~2d:~2d"
           (mod (+ 5 (local-time:timestamp-hour (local-time:now))) 24)
           (local-time:timestamp-minute (local-time:now)))))

(defun laconic-format-status (window)
  (flet ((input-indicating-background ()
           (format nil "background-color: ~:[#556B2F~;#CD5C5C~]"
                   (or (current-mode 'vi-insert)
                       (current-mode 'input-edit)))))
    (let ((buffer (current-buffer window)))
      (markup:markup
       (:div :id "container"
             (:div :id "controls" :class "arrow-right"
                   :style (input-indicating-background)
                   (markup:raw ""))
             (:div :id "url" :class "arrow-right"
                   (markup:raw
                    (laconic-format-status-url buffer)))
             (:div :id "tabs"
                   (title buffer))
             (:div :id "modes" :class "arrow-left"
                   :title (nyxt::list-modes buffer)
                   (laconic-format-status-modes buffer window)))))))

(define-configuration window
  ((status-formatter #'laconic-format-status)))
