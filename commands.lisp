(in-package #:nyxt-user)

(define-command-global eval-expression ()
  "Prompt for the expression and evaluate it, echoing result to the `message-area'.
Part of this is functionality is built into execute-command on 3.*.
BUT: this one lacks error handling, so I often use it for Nyxt-internal debugger."
  (let ((expression-string
          ;; Read an arbitrary expression. No error checking, though.
          (first (prompt :prompt "Expression to evaluate"
                         :sources (list (make-instance 'prompter:raw-source))))))
    ;; Message the evaluation result to the message-area down below.
    (echo "~S" (eval (read-from-string expression-string)))))

(defvar unicode '()
  "All the Unicode characters (or, well, all the characters the implementation supports.)")

(define-class unicode-source (prompter:source)
  ((prompter:name "Unicode character")
   (prompter:filter-preprocessor #'prompter:filter-exact-matches)
   (prompter:constructor (lambda ()
                           (or unicode
                               (setf unicode
                                     (loop for i from 0
                                           while (ignore-errors (code-char i))
                                           collect (code-char i))))))))

(defmethod prompter:object-attributes ((char character) (source unicode-source))
  `(("Character" ,(if (graphic-char-p char)
                      (princ-to-string char)
                      (format nil "~s" char)))
    ("Name" ,(char-name char))
    ("Code" ,(format nil "~D/~:*~X" (char-code char)))))

(define-command-global insert-unicode (&key (character (prompt :prompt "Character to insert"
                                                               :sources 'unicode-source)))
  "Insert the chosen Unicode character."
  (ffi-buffer-paste (string character)))

(nyxt/mode/bookmarklets:define-bookmarklet-command-global
   post-to-hn
   "Post the link you're currently on to Hacker News"
   "window.location=\"https://news.ycombinator.com/submitlink?u=\" + encodeURIComponent(document.location) + \"&t=\" + encodeURIComponent(document.title)")

(define-command-global open-in-nosave-buffer ()
  "Make a new nosave buffer with URL at point."
  (let ((url (url-at-point (current-buffer))))
    (make-nosave-buffer :url url)))

(ffi-add-context-menu-command
 (lambda ()
   (when (url-at-point (current-buffer))
     (make-nosave-buffer :url (url-at-point (current-buffer)))))
 "Open Link in New Nosave Buffer")

#+nyxt-gtk
(define-command-global make-new-buffer-with-url-and-context ()
  "Make a new buffer with a user-chosen context and a URL under pointer."
  (nyxt/renderer/gtk:make-buffer-with-context :url (url-at-point (current-buffer))))

(ffi-add-context-menu-command
 'make-new-buffer-with-url-and-context
 "Open Link in New Buffer with Context")

(define-panel-command-global search-translate-selection (&key (selection (ffi-buffer-copy (current-buffer))))
    (panel "*Translate panel*" :right)
  "Open the translation of the selected word in a panel buffer."
  (setf (ffi-width panel) 550)
  (run-thread "search translation URL loader"
    (sleep 0.3)
    (buffer-load (quri:uri (format nil (nyxt::search-url (nyxt::default-search-engine))
                                   (str:concat "translate " (ffi-buffer-copy (current-buffer)))))
                 :buffer panel))
  "")

(ffi-add-context-menu-command
 'search-translate-selection
 "Translate Selection")

(define-command-global add-autofill ()
  "Add an autofill with the selected text to the list of `autofill-mode' autofills."
  (push (make-instance 'nyxt/mode/autofill:autofill
                       :name (prompt1 :prompt "Autofill key" :sources 'prompter:raw-source)
                       :fill (ffi-buffer-copy (current-buffer)))
        (nyxt/mode/autofill::autofills (current-mode :autofill))))

(ffi-add-context-menu-command
 'add-autofill
 "Add Temporary Autofill")

(ffi-add-context-menu-command
 (lambda ()
   (let ((url (url-at-point (current-buffer))))
     (nyxt/mode/bookmark:bookmark-add url :title (fetch-url-title url))))
 "Bookmark this URL")

(defmethod nyxt:value->html :around ((value string) &optional compact-p)
  (declare (ignorable compact-p))
  (if (html-string-p value)
      (spinneret:with-html-string
        (:label
         (:raw (call-next-method))
         (:br)
         (:raw value)))
      (call-next-method)))

(defun make-clcs-link (symbol)
  (str:concat "https://cl-community-spec.github.io/pages/"
              (str:replace-all "-" "_002d" symbol)))

(defmemo ping-clcs (symbol)
  (handler-case
      (prog1
          t
        (dex:get (make-clcs-link symbol)))
    (error () nil)))

(define-command-global clcs-lookup ()
  (prompt
   :sources (list (make-instance
                   'prompter:source
                   :name "CL symbols"
                   :constructor (mapcar #'prini-to-string
                                        (nsymbols:package-symbols :cl :visibility :external))
                   :enable-marks-p t
                   :filter-postprocessor #'(lambda (suggestions source input)
                                             (declare (ignorable source input))
                                             (remove-if (complement #'ping-clcs) suggestions
                                                        :key #'prompter:value))
                   :actions-on-return (list
                                       (lambda-command clcs-current-buffer* (symbols)
                                         (mapcar (alexandria:curry #'make-buffer-focus :url)
                                                 (mapcar #'make-clcs-link (rest symbols)))
                                         (buffer-load (make-clcs-link (first symbols))))
                                       (lambda-command clcs-new-buffer* (symbols)
                                         (mapcar (alexandria:curry #'make-buffer-focus :url)
                                                 (mapcar #'make-clcs-link symbols))))))))
