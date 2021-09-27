(in-package #:nyxt-user)

;;; Display modes as short glyphs (listed below) in the mode line
;;; (bottom-right of the screen).
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
(define-configuration nyxt/web-mode:web-mode ((glyph "ω")))
(define-configuration nyxt/auto-mode:auto-mode ((glyph "α")))

;; (defun laconic-format-status-modes (buffer window)
;;   (spinneret:with-html-string
;;     (when (nosave-buffer-p buffer) (:span "⚠ nosave"))
;;     (:span (format nil "~2d:~2d |"
;;                    (mod (+ 5 (local-time:timestamp-hour (local-time:now))) 24)
;;                    (local-time:timestamp-minute (local-time:now))))
;;     (:a :class "button"
;;         :href (lisp-url '(nyxt:toggle-modes))
;;         :title (str:concat "Enabled modes: " (nyxt::list-modes buffer)) "⊕")
;;     (loop for mode in (serapeum:filter #'visible-in-status-p (modes buffer))
;;           collect (:a :class "button" :href (lisp-url `(describe-class ',(mode-name mode)))
;;                       :title (format nil "Describe ~a" (mode-name mode))
;;                       (if (glyph-mode-presentation-p (status-buffer window))
;;                           (glyph mode)
;;                           (nyxt::format-mode mode))))))

;; (defun format-status-vi-mode (&optional (buffer (current-buffer)))
;;   (spinneret:with-html-string
;;     (cond ((find-submode buffer 'vi-normal-mode)
;;            (:div
;;             (:a :class "button" :title "vi-normal-mode" :href (lisp-url '(nyxt/vi-mode:vi-insert-mode)) "N")))
;;           ((find-submode buffer 'vi-insert-mode)
;;            (:div
;;             (:a :class "button" :title "vi-insert-mode" :href (lisp-url '(nyxt/vi-mode:vi-normal-mode)) "I")))
;;           (t (:span "")))))


;; (defun laconic-format-status-load-status (buffer)
;;   (spinneret:with-html-string
;;     (:div :class (if (web-buffer-p buffer)
;;                      (case (slot-value buffer 'nyxt::load-status)
;;                        (:unloaded "∅")
;;                        (:loading "∞")
;;                        (:finished ""))
;;                      ""))))

;; (defun laconic-format-status-url (buffer)
;;   (spinneret:with-html-string
;;     (:a :class "button"
;;         :href (lisp-url '(nyxt:set-url))
;;         (format nil " ~a — ~a"
;;                 (ppcre:regex-replace-all
;;                  "(https://|www\\.|/$)"
;;                  (render-url (url buffer))
;;                  "")
;;                 (title buffer)))))

;; (defun laconic-format-status (window)
;;   (let* ((buffer (current-buffer window))
;;          (vi-class (cond ((find-submode buffer 'vi-normal-mode)
;;                           "vi-normal-mode")
;;                          ((or (find-submode buffer 'vi-insert-mode)
;;                               (find-submode buffer 'input-edit-mode))
;;                           "vi-insert-mode"))))
;;     (spinneret:with-html-string
;;       (:div :id (if vi-class "container-vi" "container")
;;             (:div :id "controls" :class "arrow-right")
;;             (when vi-class
;;               (:div :id "vi-mode" :class (str:concat vi-class " arrow-right")
;;                     (:raw (nyxt::format-status-vi-mode buffer))))
;;             (:div :id "url" :class "arrow-right"
;;                   (:raw
;;                    (laconic-format-status-load-status buffer)
;;                    (laconic-format-status-url buffer)))
;;             (:div :id "tabs"
;;                   (:raw
;;                    (nyxt::format-status-tabs)))
;;             (:div :id "modes" :class "arrow-left"
;;                   :title (nyxt::list-modes buffer)
;;                   (:raw
;;                    (laconic-format-status-modes buffer window)))))))

;; (define-configuration window
;;   ((status-formatter #'laconic-format-status)))
