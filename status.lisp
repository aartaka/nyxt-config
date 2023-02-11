(in-package #:nyxt-user)

;;; Display modes as short glyphs (listed below) in the mode line
;;; (bottom-right of the screen).
(define-configuration status-buffer
  ((glyph-mode-presentation-p t)))

(define-configuration nyxt/force-https-mode:force-https-mode ((glyph "ϕ")))
#+nyxt-3
(define-configuration nyxt/user-script-mode:user-script-mode ((glyph "u")))
(define-configuration nyxt/blocker-mode:blocker-mode ((glyph "β")))
(define-configuration nyxt/proxy-mode:proxy-mode ((glyph "π")))
(define-configuration nyxt/reduce-tracking-mode:reduce-tracking-mode
  ((glyph "τ")))
(define-configuration nyxt/certificate-exception-mode:certificate-exception-mode
  ((glyph "χ")))
(define-configuration nyxt/style-mode:style-mode ((glyph "ϕ")))
#+(or nyxt-2 nyxt-3-pre-release-1)
(define-configuration nyxt/auto-mode:auto-mode ((glyph "α")))
(define-configuration nyxt/cruise-control-mode:cruise-control-mode ((glyph "σ")))

#+nyxt-3
(define-configuration status-buffer
  ((style (str:concat
           %slot-value%
           (theme:themed-css (theme *browser*)
             `("#controls,#tabs"
               :display none !important))))))

(local-time:reread-timezone-repository)

#+nyxt-3
(defmethod format-status-modes :around ((status status-buffer))
  (spinneret:with-html-string
    (:raw (call-next-method))
    (:span (format nil "| ~2d:~2d"
                   (local-time:timestamp-hour
                    (local-time:now)
                    :timezone (local-time:find-timezone-by-location-name "Asia/Yerevan"))
                   (local-time:timestamp-minute (local-time:now))))))

#+nyxt-3
(defmethod format-status-load-status ((status status-buffer))
  (spinneret:with-html-string
    (:span (if (web-buffer-p (current-buffer))
               (case (slot-value (current-buffer) 'nyxt::status)
                 (:unloaded "∅")
                 (:loading "∞")
                 (:finished ""))
               ""))))
