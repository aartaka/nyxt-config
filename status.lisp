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
   (:a :class "button"
       (format nil "~a ~a — ~a"
               (laconic-format-status-load-status buffer)
               (ppcre:regex-replace-all
                "(https://|www\\.|/$)"
                (render-url (url buffer))
                "")
               (title buffer)))))

(defun laconic-format-status-modes (buffer window)
  (str:concat
   (format-status-modes buffer window)
   " | "
   (format nil "~d:~d"
           (local-time:timestamp-hour (local-time:now))
           (local-time:timestamp-minute (local-time:now)))))

(defun laconic-format-status (window)
  (flet ((input-indicating-background ()
           (format nil "background-color: ~:[#556B2F~;#CD5C5C~]"
                   (or (current-mode 'vi-insert)
                       (current-mode 'input-edit)))))
    (let ((buffer (current-buffer window)))
      (markup:markup
       (:div :id "container"
             (:div :id "controls"
                   :style (input-indicating-background)
                   (markup:raw ""))
             (:div :class "arrow arrow-right"
                   :style (input-indicating-background) "")
             (:div :id "url"
                   (markup:raw
                    (laconic-format-status-url buffer)))
             (:div :class "arrow arrow-right"
                   :style "background-color:rgb(0,0,0)" "")
             ;; Need to figure out what to put there.
             (:div :id "tabs"
                   :style "background-color: darkdray" "")
             (:div :class "arrow arrow-left"
                   :style "background-color:rgb(0,0,0)" "")
             (:div :id "modes"
                   :title (nyxt::list-modes buffer)
                   (laconic-format-status-modes buffer window)))))))

(define-configuration window
  ((status-formatter #'laconic-format-status)))
