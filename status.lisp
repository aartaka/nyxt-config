(in-package #:nyxt-user)

(define-configuration :status-buffer
  "Display modes as short glyphs."
  ((glyph-mode-presentation-p t)))

(define-configuration :force-https-mode ((glyph "ϕ")))
(define-configuration :user-script-mode ((glyph "u")))
(define-configuration :blocker-mode ((glyph "β")))
(define-configuration :proxy-mode ((glyph "π")))
(define-configuration :reduce-tracking-mode ((glyph "τ")))
(define-configuration :certificate-exception-mode ((glyph "χ")))
(define-configuration :style-mode ((glyph "ϕ")))
(define-configuration :cruise-control-mode ((glyph "σ")))

(define-configuration status-buffer
  "Hide most of the status elements but URL and modes."
  ((style (str:concat
           %slot-value%
           (theme:themed-css (theme *browser*)
                             `("#controls,#tabs"
                               :display none !important))))))

(defmethod format-status-load-status ((status status-buffer))
  "A fancier load status."
  (spinneret:with-html-string
   (:span (if (and (current-buffer)
                   (web-buffer-p (current-buffer)))
              (case (slot-value (current-buffer) 'nyxt::status)
                    (:unloaded "∅")
                    (:loading "∞")
                    (:finished ""))
            ""))))
