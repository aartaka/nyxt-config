(in-package #:nyxt-user)

;;; Display modes as short glyphs (listed below) in the mode line
;;; (bottom-right of the screen).
(define-configuration status-buffer
  ((glyph-mode-presentation-p t)))

(define-configuration :force-https-mode ((glyph "ϕ")))
#+nyxt-3
(define-configuration :user-script-mode ((glyph "u")))
(define-configuration :blocker-mode ((glyph "β")))
(define-configuration :proxy-mode ((glyph "π")))
(define-configuration :reduce-tracking-mode
  ((glyph "τ")))
(define-configuration :certificate-exception-mode
  ((glyph "χ")))
(define-configuration :style-mode ((glyph "ϕ")))
#+(or nyxt-2 nyxt-3-pre-release-1)
(define-configuration nyxt/auto-mode:auto-mode ((glyph "α")))
(define-configuration :cruise-control-mode ((glyph "σ")))

;; Remove most of the status elements but URL and modes.
#+nyxt-3
(define-configuration status-buffer
  ((style (str:concat
           %slot-value%
           (theme:themed-css (theme *browser*)
             `("#controls,#tabs"
               :display none !important))))))

;; A fancier load status.
#+nyxt-3
(defmethod format-status-load-status ((status status-buffer))
  (spinneret:with-html-string
    (:span (if (web-buffer-p (current-buffer))
               (case (slot-value (current-buffer) 'nyxt::status)
                 (:unloaded "∅")
                 (:loading "∞")
                 (:finished ""))
               ""))))
