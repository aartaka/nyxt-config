(in-package #:nyxt-user)

(defun format-short-status-modes (&optional (buffer (current-buffer)))
  "A shorter version of built-in `format-status-modes'.

Main difference: the modes I personally use often are replaced
with (mostly) Greek letters."
  (str:replace-using
   '("-mode" ""
     "base" ""
     "emacs" "ξ" ; Xi looks like Emacs logo...
     "force-https" "ϕ"
     "auto" "α"
     "blocker" "β"
     "proxy" "π"
     "reduce-tracking" "τ"
     "certificate-exception" "χ"
     "style" "σ"
     "web" "ω"
     "help" "?")
   (format nil "~{~a~^ ~}"
           (mapcar (alexandria:compose #'str:downcase #'mode-name)
                   (modes buffer)))))

(defun format-short-status-load-status (&optional (buffer (current-buffer)))
  "A shorter version of built-in `format-status-load-status'.
Glyphs are used to reflect the `load-status' other than :finished."
  (when (web-buffer-p buffer)
    (case (slot-value buffer 'nyxt::load-status)
      (:unloaded "∅")
      (:loading "∞")
      (:finished ""))))

(defun format-short-status-url (&optional (buffer (current-buffer)))
  "A shorter version of built-in `format-status-url'.
Strips all the obvious decorations (HTTPS scheme, WWW prefix, trailing
slashes) off the URL."
  (markup:markup
   (str:concat
        (format-short-status-load-status buffer)
        (format nil " ~a — ~a"
                (ppcre:regex-replace-all
                 "(https://|www\\.|/$)"
                 (object-display (url buffer))
                 "")
                (title buffer)))))

(defun short-format-status (window)
  "An alternative version of built-in `nyxt::format-status'.
Most sub-functions are replaced with shorter counterparts."
  (let ((buffer (current-buffer window)))
    (markup:markup
     (:div :id "container"
           (:div :id "controls" (markup:raw ""))
           (:div :class "arrow arrow-right"
                 :style "background-color:rgb(80,80,80)" "")
           (:div :id "url" (markup:raw (format-short-status-url buffer)))
           (:div :class "arrow arrow-right"
                 :style "background-color:rgb(120,120,120)" "")
           (:div :id "tabs" (markup:raw ""))
           (:div :class "arrow arrow-left"
                 :style (format nil "background-color: ~:[#CD5C5C~;#556B2F~];"
                                 (find-submode buffer 'nyxt/vi-mode:vi-insert-mode)) "")
           (:div :id "modes"
                 :style (format nil "background-color: ~:[#CD5C5C~;#556B2F~];"
                                 (find-submode buffer 'nyxt/vi-mode:vi-insert-mode))
                 (format-short-status-modes buffer))))))

(define-configuration window
  ((status-formatter #'short-format-status)))
