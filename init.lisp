(in-package #:nyxt-user)

(load-after-system :slynk (nyxt-init-file "slynk.lisp"))

(define-configuration browser
  ((session-restore-prompt :always-ask)))

(defun format-short-status-modes (&optional (buffer (current-buffer)))
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
  (when (web-buffer-p buffer)
    (case (slot-value buffer 'nyxt::load-status)
      (:unloaded "∅")
      (:loading "∞")
      (:finished ""))))

(defun format-short-status-url (&optional (buffer (current-buffer)))
  (markup:markup
   (:a :class "button"
       :href (lisp-url '(nyxt:set-url-from-current-url))
       (str:concat
        (format-short-status-load-status buffer)
        (format nil " ~a — ~a"
                (ppcre:regex-replace-all
                 "(https://|www\\.|/$)"
                 (object-display (url buffer))
                 "")
                (title buffer))))))

(defun short-format-status (window)
  (let ((buffer (current-buffer window)))
    (markup:markup
     (:div :id "container"
           (:div :id "controls" (markup:raw ""))
           (:div :class "arrow arrow-right"
                 :style "background-color:rgb(80,80,80)" "")
           (:div :id "url" (markup:raw (format-short-status-url buffer)))
           (:div :class "arrow arrow-right"
                 :style "background-color:rgb(120,120,120)" "")
           (:div :id "tabs" (markup:raw (format-status-tabs)))
           (:div :class "arrow arrow-left"
                 :style "background-color:rgb(120,120,120)" "")
           (:div :id "modes" (format-short-status-modes buffer))))))

(define-configuration window
  ((status-formatter #'short-format-status)
   (message-buffer-style
    (str:concat
     %slot-default
     (cl-css:css
      '((body
         :background-color "black"
         :color "white")))))))

(define-configuration minibuffer
  ((style
    (str:concat
     %slot-default
     (cl-css:css
      '((body
         :background-color "black"
         :color "#808080")))))))

(define-configuration buffer
  ((default-modes `(emacs-mode ,@%slot-default))
   (conservative-word-move t)
   ;; QWERTY home row.
   (hints-alphabet "DSJKHLFAGNMXCWEIO")))

(define-configuration web-buffer
  ((default-modes `(emacs-mode auto-mode blocker-mode force-https-mode
                               ,@%slot-default))))

(define-configuration internal-buffer
  ((style
    (str:concat
     %slot-default
     (cl-css:css
      '((body
         :background-color "black"
         :color "lightgray")
        (hr
         :color "darkgray")
        (.button
         :color "#333333")))))))

(define-configuration nyxt/auto-mode:auto-mode
  ((nyxt/auto-mode:prompt-on-mode-toggle t)))
