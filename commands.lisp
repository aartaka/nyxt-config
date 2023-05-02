(in-package #:nyxt-user)

;; This is built into execute-command on 3.*.
#+nyxt-2
(define-command-global eval-expression ()
  "Prompt for the expression and evaluate it, echoing result to the `message-area'."
  (let ((expression-string
          ;; Read an arbitrary expression. No error checking, though.
          (first (prompt :prompt "Expression to evaluate"
                         :sources (list (make-instance 'prompter:raw-source))))))
    ;; Message the evaluation result to the message-area down below.
    (echo "~S" (eval (read-from-string expression-string)))))

#+(and nyxt-3 (not nyxt-3-pre-release-1))
(#+(or 3-pre-release-2 3-pre-release-3 3-pre-release-4 3-pre-release-5 3-pre-release-6)
 nyxt/bookmarklets-mode:define-bookmarklet-command-global
   #-(or 3-pre-release-2 3-pre-release-3 3-pre-release-4 3-pre-release-5 3-pre-release-6)
   nyxt/mode/bookmarklets:define-bookmarklet-command-global
   post-to-hn
   "Post the link you're currently on to Hacker News"
   "window.location=\"https://news.ycombinator.com/submitlink?u=\" + encodeURIComponent(document.location) + \"&t=\" + encodeURIComponent(document.title)")

(define-command-global open-in-nosave-buffer ()
  "Make a new nosave buffer with URL at point."
  (let ((url (url-at-point (current-buffer))))
    (make-nosave-buffer :url url)))

#+(and nyxt-3 (not nyxt-3-pre-release-1))
(ffi-add-context-menu-command
 (lambda ()
   (when (url-at-point (current-buffer))
     (make-nosave-buffer :url (url-at-point (current-buffer)))))
 "Open Link in New Nosave Buffer")

#+(and nyxt-gtk nyxt-3)
(define-command-global make-new-buffer-with-url-and-context ()
  "Make a new buffer with a user-chosen context and a URL under pointer."
  (#-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
   make-buffer-with-context
   #+(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
   nyxt/renderer/gtk:make-buffer-with-context
   :url (url-at-point (current-buffer))))

#+(and nyxt-gtk nyxt-3 (not nyxt-3-pre-release-1))
(ffi-add-context-menu-command
 'make-new-buffer-with-url-and-context
 "Open Link in New Buffer with Context")

#+nyxt-3
(define-panel-command-global search-translate-selection (&key (selection (ffi-buffer-copy (current-buffer))))
    (panel "*Translate panel*" :right)
  "Open the translation of the selected word in a panel buffer."
  (setf
   #-(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
   (ffi-window-panel-buffer-width (current-window) panel)
   #+(and nyxt-3 (not (or nyxt-3-pre-release-2 nyxt-3-pre-release-1)))
   (ffi-width panel) 550)
  (run-thread "search translation URL loader"
    (sleep 0.3)
    (buffer-load (quri:uri (format nil (nyxt::search-url (nyxt::default-search-engine))
                                   (str:concat "translate " (ffi-buffer-copy (current-buffer)))))
                 :buffer panel))
  "")

#+(and nyxt-3 (not nyxt-3-pre-release-1))
(ffi-add-context-menu-command
 'search-translate-selection
 "Translate Selection")

#+(and nyxt-3 (or 3-pre-release-1 3-pre-release-2 3-pre-release-3 3-pre-release-4 3-pre-release-5 3-pre-release-6))
(define-command-global add-autofill ()
  "Add an autofill with the selected text to the list of `autofill-mode' autofills."
  (push (make-instance 'nyxt/autofill-mode:autofill
                       :name (prompt1 :prompt "Autofill key" :sources 'prompter:raw-source)
                       :fill (ffi-buffer-copy (current-buffer)))
        (nyxt/autofill-mode::autofills (current-mode :autofill))))
#+nyxt-3
(define-command-global add-autofill ()
  "Add an autofill with the selected text to the list of `autofill-mode' autofills."
  (push (make-instance 'nyxt/mode/autofill:autofill
                       :name (prompt1 :prompt "Autofill key" :sources 'prompter:raw-source)
                       :fill (ffi-buffer-copy (current-buffer)))
        (nyxt/mode/autofill::autofills (current-mode :autofill))))

#+(and nyxt-3 (not nyxt-3-pre-release-1))
(ffi-add-context-menu-command
 'add-autofill
 "Add Temporary Autofill")

#+(and nyxt-3 (not nyxt-3-pre-release-1))
(ffi-add-context-menu-command
 (lambda ()
   (let ((url (url-at-point (current-buffer))))
     (#+(or 3-pre-release-1 3-pre-release-2 3-pre-release-3 3-pre-release-4 3-pre-release-5 3-pre-release-6)
      nyxt/bookmark-mode:bookmark-add
      #-(or 3-pre-release-1 3-pre-release-2 3-pre-release-3 3-pre-release-4 3-pre-release-5 3-pre-release-6)
      nyxt/mode/bookmark:bookmark-add
      url :title (fetch-url-title url))))
 "Bookmark this URL")

#+nyxt-3
(defmethod nyxt:value->html :around ((value string) &optional compact-p)
  (declare (ignorable compact-p))
  (if (html-string-p value)
      (spinneret:with-html-string
        (:label
         (:raw (call-next-method))
         (:br)
         (:raw value)))
      (call-next-method)))
