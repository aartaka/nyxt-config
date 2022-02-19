(in-package #:nyxt-user)

;;;; My color preferences weren't satisfied by any Emacs theme, so I
;;;; wrote mine: Laconia (https://github.com/aartaka/laconia). This
;;;; file is simply a translation of Laconia colors to Nyxt interface.
;;;;
;;;; This only works on the versions of Nyxt after 2.2.4. For the
;;;; backwards-compatible solution, see previous versions of this
;;;; file.
(define-configuration browser
  ((theme (make-instance
           'theme:theme
           :dark-p t
           :background-color "black"
           :text-color "white"
           :accent-color "#CD5C5C"
           :primary-color "#556B2F"
           :secondary-color "lightgray"
           :tertiary-color "gray"
           :quaternary-color "dimgray"))))

;;; Dark-mode is a simple mode for simple HTML pages to color those in
;;; a darker palette. I don't like the default gray-ish colors,
;;; though. Thus, I'm overriding those to be a bit more laconia-like.
(define-configuration nyxt/style-mode:dark-mode
  ((style #.(cl-css:css
             '((*
                :background-color "black !important"
                :background-image "none !important"
                :color "white")
               (a
                :background-color "black !important"
                :background-image "none !important"
                :color "#556B2F !important"))))))

(define-mode dark-reader-mode ()
  "A mode to load Dark Reader script and run it on the page."
  ((script nil)
   (destructor (lambda (mode)
                 (ffi-buffer-remove-user-script (buffer mode) (script mode))))
   (constructor (lambda (mode)
                  (setf (script mode)
                        (ffi-buffer-add-user-script
                         (buffer mode)
                         (str:concat (uiop:read-file-string
                                      (nyxt-init-file "darkreader.min.js"))
                                     "
DarkReader.enable({
	brightness: 100,
	contrast: 100,
	sepia: 0,
    darkSchemeBackgroundColor: 'black',
    darkSchemeTextColor: 'white',
    selectionColor: '#CD5C5C'
});")
                         :all-frames-p nil
                         :at-document-start-p nil
                         :allow-list '("http://*/*" "https://*/*")))))))
