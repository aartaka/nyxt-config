(in-package #:nyxt-user)

(defmacro append-style (class slot &body rules)
  "Expand to the `define-configuration' form styling SLOT of CLASS.
RULES are put inside a `cl-css:css' as a list, so

\(append-style window message-buffer-style
  (body
   :background-color \"black\"
   :color \"white\"))

is equivalent to

\(define-configuration window
  ((message-buffer-style
    (str:concat
     %slot-default%
     (cl-css:css
      '((body
         :background-color \"black\"
         :color \"white\")))))))"
  `(define-configuration ,class
     ((,slot
       (str:concat
        %slot-default%
        (cl-css:css
         (quote ,rules)))))))

(defmacro define-theme ((&key dark-theme-p generate-dark-mode-style-p)
                        (&key (base-color "white") (text-color "black")
                              ;; Original Nyxt styles have:
                              ;; - dimgray - 3 times,
                              ;; - gray - 6 times,
                              ;; - lightgray - 4 times,
                              ;; - darkgray - 2
                              ;; But dimgray is too close to gray to
                              ;; consider it, thus it's replaced by plain
                              ;; gray.
                           (primary-color "gray") (secondary-color "lightgray") (tertiary-color "darkgray")
                           (accent-color "#37a8e4")))
  "Define a color theme loosely matching that of default Nyxt theme, just with colors swapped.

DARK-THEME-P is whether the theme you define is a dark or a light one.
GENERATE-DARK-MODE-STYLE-P is whether the `nyxt/style-mode:dark-mode'
colors will be generated based on the colors (works with DARK-THEME-P
both set to t or nil).

BASE-COLOR is the background color.
TEXT-COLOR is... a color text will be painted in.
PRIMARY-COLOR is the color most interface elements (like buttons and
links) are painted in.
SECONDARY-COLOR is the color close to PRIMARY-COLOR used alongside it.
TERTIARY-COLOR is the rare color to use with previous two.
ACCENT-COLOR is the bright color to focus attention on things.

Important rules to stick to:
TEXT-COLOR and BASE-COLOR should be contrasting enough.
PRIMARY-COLOR should be more or less contrasting with both TEXT-COLOR
and BASE-COLOR.
SECONDARY-COLOR should contrast with TEXT-COLOR.
TERTIARY-COLOR should contrast with BASE-COLOR.
ACCENT-COLOR should contrast both TEXT-COLOR and BASE-COLOR
(although that's rarely possible)."
  (flet ((brightness (dark-p)
           (if dark-p
               "brightness(0.7)"
               "brightness(1.4)")))
    `(progn
       (append-style window message-buffer-style
         (body
          :background-color ,base-color
          :color ,text-color))
       (append-style prompt-buffer style
         (body
          :background ,base-color
          :color ,text-color)
         ("#prompt-area"
          :background-color ,primary-color
          :color ,text-color)
         ("#input"
          :background-color ,base-color
          :color ,text-color)
         (".source-name"
          :background-color ,primary-color)
         (".source-content"
          :background-color ,base-color)
         (".source-content th"
          :background-color ,base-color)
         ("#selection"
          :background-color ,accent-color
          :color ,base-color)
         (.marked :background-color ,primary-color
                  :filter ,(brightness dark-theme-p)
                  :color ,base-color)
         (.selected :background-color ,primary-color
                    :color ,base-color))
       (append-style internal-buffer style
         (body
          :background ,base-color
          :color ,text-color)
         (hr
          :color ,secondary-color
          :background-color ,secondary-color)
         (.button
          :background-color ,primary-color
          :color ,base-color)
         (|.button:hover|
          :color ,text-color)
         (|.button:visited|
          :color ,base-color)
         (|.button:active|
          :color ,base-color))
       (append-style nyxt/history-tree-mode:history-tree-mode
           nyxt/history-tree-mode::style
         (body
          :background-color ,base-color
          :color ,text-color)
         (a
          :color ,text-color)
         ("a:hover"
          :color ,primary-color)
         (".current-buffer a"
          :color ,text-color)
         (".current-buffer a:hover"
          :color ,primary-color)
         (".other-buffer a"
          :color ,primary-color)
         (".other-buffer a:hover"
          :color ,secondary-color)
         ("ul li::before"
          :background-color ,text-color)
         ("ul li:only-child::before"
          :background-color ,text-color)
         ("ul li::after"
          :background-color ,text-color))
       (append-style nyxt/list-history-mode:list-history-mode
           nyxt/list-history-mode::style
         (a
          :color ,text-color)
         ("a:hover"
          :color ,primary-color))
       (append-style nyxt/web-mode:web-mode
           nyxt/web-mode:highlighted-box-style
         (".nyxt-hint.nyxt-highlight-hint"
          :background ,accent-color))
       (append-style nyxt/web-mode:web-mode
           nyxt/web-mode:box-style
         (".nyxt-hint"
          :background-color ,primary-color
          :color ,base-color))
       (append-style status-buffer style
         (body
          :background-color ,base-color
          :color ,text-color)
         (.loader
          :border ,(str:concat "2px solid " text-color)
          :border-top-color ,accent-color
          :border-left-color ,accent-color)
         ("#controls"
          :background-color ,primary-color
          :color ,base-color
          :filter ,(brightness dark-theme-p))
         ("#url"
          :background-color ,primary-color
          :color ,base-color)
         ("#tabs"
          :background-color ,tertiary-color
          :color ,text-color)
         (.tab
          :color ,base-color)
         (".tab:hover"
          :color ,text-color)
         ("#modes"
          :background-color ,primary-color
          :color ,base-color)
         (.button
          :color ,base-color)
         (|.button:hover|
          :color ,text-color))
       (append-style nyxt/repl-mode:repl-mode nyxt/repl-mode::style
         (body
          :background-color ,base-color
          :color ,text-color)
         ("#input"
          :background-color ,primary-color)
         ("#input-buffer"
          :background-color ,base-color
          :color ,text-color)
         ("#prompt"
          :color ,base-color))
       (append-style download-mode style
         (body
          :background-color ,base-color
          :color ,text-color)
         (".download"
          :background-color ,base-color)
         (".download-url a"
          :color ,text-color)
         (".progress-bar-base"
          :background-color ,secondary-color)
         (".progress-bar-fill"
          :background-color ,primary-color))
       (append-style nyxt/reading-line-mode:reading-line-mode nyxt/reading-line-mode::style
         ("#reading-line-cursor"
          :background-color ,primary-color
          :opacity "15%"))
       (append-style nyxt/editor-mode:plaintext-editor-mode nyxt/editor-mode::style
         (body
          :background-color ,base-color
          :color ,text-color)
         ("#editor"
          :background-color ,base-color
          :color ,text-color))
       ,@(when generate-dark-mode-style-p
           `((append-style nyxt/style-mode:dark-mode style
               (*
                :background-color ,(str:concat (if dark-theme-p base-color text-color) " !important")
                :background-image "none !important"
                :color ,(str:concat (if dark-theme-p text-color base-color) " !important"))
               (a
                :background-color ,(str:concat (if dark-theme-p base-color text-color) " !important")
                :background-image "none !important"
                :color ,(str:concat secondary-color " !important"))))))))

(define-theme
    (:dark-theme-p t
     :generate-dark-mode-style-p t)
    (:base-color "black"
     :text-color "white"
     :accent-color "#CD5C5C"
     :primary-color "#556B2F"
     :tertiary-color "gray"))

;; (append-style window message-buffer-style
;;   (body
;;    :background-color "black"
;;    :color "white"))

;; (append-style prompt-buffer style
;;   (body
;;    :background-color "black"
;;    :color "white")
;;   ("#prompt-area"
;;    :background-color "black")
;;   ("#input"
;;    :background-color "white")
;;   (".source-name"
;;    :color "black"
;;    :background-color "#556B2F")
;;   (".source-content"
;;    :background-color "black")
;;   (".source-content th"
;;    :border "1px solid #556B2F"
;;    :background-color "black")
;;   ("#selection"
;;    :background-color "#CD5C5C"
;;    :color "black")
;;   (.marked :background-color "#8B3A3A"
;;            :font-weight "bold"
;;            :color "white")
;;   (.selected :background-color "black"
;;              :color "white"))

;; (append-style internal-buffer style
;;   (body
;;    :background-color "black"
;;    :color "lightgray")
;;   (hr
;;    :color "darkgray")
;;   (a
;;    :color "#556B2F")
;;   (.button
;;    :color "lightgray"
;;    :background-color "#556B2F"))

;; (append-style nyxt/history-tree-mode:history-tree-mode
;;     nyxt/history-tree-mode::style
;;   (body
;;    :background-color "black"
;;    :color "lightgray")
;;   (hr
;;    :color "darkgray")
;;   (a
;;    :color "#556B2F")
;;   ("ul li::before"
;;    :background-color "white")
;;   ("ul li::after"
;;    :background-color "white")
;;   ("ul li:only-child::before"
;;    :background-color "white"))

;; (append-style nyxt/web-mode:web-mode
;;     nyxt/web-mode:highlighted-box-style
;;   (".nyxt-hint.nyxt-highlight-hint"
;;    :background "#CD5C5C"))

;; (append-style status-buffer style
;;   ("#controls"
;;    :border-top "1px solid white")
;;   ("#url"
;;    :background-color "black"
;;    :color "white"
;;    :border-top "1px solid white")
;;   ("#modes"
;;    :background-color "black"
;;    :border-top "1px solid white")
;;   ("#tabs"
;;    :background-color "#CD5C5C"
;;    :color "black"
;;    :border-top "1px solid white"))

;; (append-style nyxt/style-mode:dark-mode style
;;   (*
;;    :background-color "black !important"
;;    :background-image "none !important"
;;    :color "white !important")
;;   (a
;;    :background-color "black !important"
;;    :background-image "none !important"
;;    :color "#556B2F !important"))
