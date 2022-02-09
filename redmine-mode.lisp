(uiop:define-package :redmine-mode
  (:use :common-lisp :nyxt)
  (:import-from #:class-star #:define-class)
  (:import-from #:keymap #:define-key #:define-scheme)
  (:import-from #:serapeum #:->)
  (:documentation "Mode for Redmine automation."))

(in-package :redmine-mode)
(use-nyxt-package-nicknames)

(define-mode redmine-mode ()
  "A mode for Redmine automation."
  ((keymap-scheme
    (define-scheme "redmine-mode"
      scheme:cua
      (list
       "C-c n" 'new-issue
       "C-c e" 'edit-issue
       "C-c c" 'copy-issue
       "C-c l" 'log-issue
       "C-c t" 'toggle-issue-status
       "C-c d" 'new-document
       "C-return" 'done)))
   (destructor
    (lambda (mode)
      (declare (ignorable mode))))
   (constructor
    (lambda (mode)
      (declare (ignorable mode))))))

(defvar *redmine-host* nil
  "The host Redmine instance is running on")

(defun on-redmine-p (url)
  (if *redmine-host*
      (string-equal (quri:uri-host url) *redmine-host*)
      t))

(defun in-project-p (url)
  (and (on-redmine-p url)
       (or (and (cl-ppcre:all-matches "/projects/.*" (quri:uri-path url))
                (elt (str:split "/" (quri:uri-path url) :omit-nulls t) 1))
           (and (cl-ppcre:all-matches "/issues/[0-9]+" (quri:uri-path url))
                (elt (str:split "/" (quri:uri-path
                                     (url (elt (clss:select "span.position > a"
                                                 (document-model (current-buffer))) 0)))
                                :omit-nulls t)
                     1)))))

(defun redmine-url (default-url &key (project (in-project-p default-url))
                                  (issue (in-issue-p default-url))
                                  action)
  (quri:copy-uri default-url
                 :path (format nil "/projects/~a/issues/~:[~*~;~a/~]~:[~*~;~a~]"
                               project project
                               issue issue
                               action action)
                 :query nil
                 :fragment nil))

(define-command new-issue ()
  "Open a new issue in the currently opened project."
  (let* ((url (url (current-buffer)))
         (new-url (redmine-url url :issue "new")))
    (if (in-project-p url)
        (buffer-load new-url)
        (echo-warning "You're not in a project at the moment!"))))

(defun in-issue-p (url)
  (and (on-redmine-p url)
       (cl-ppcre:all-matches "/issues/[0-9]+" (quri:uri-path url))
       (parse-integer (alex:lastcar (str:split "/" (quri:uri-path url) :omit-nulls t)))))

(define-class issue ()
  ((issue-number)
   (name "")
   (status)
   (assignee))
  (:export-class-name-p t)
  (:export-accessor-names-p t)
  (:accessor-name-transformer (class*:make-name-transformer name))
  (:documentation "The representation of Redmine issue containing the most important info on it."))

(defmethod prompter:object-attributes ((issue issue))
  `(("#" ,(issue-number issue))
    ("Status" ,(status issue))
    ("Assignee" ,(assignee issue))
    ("Name" ,(name issue))))

(define-class issue-source (prompter:source)
  ((prompter:name "Issues")
   (prompter:constructor
    (lambda (source)
      (declare (ignore source))
      (let* ((url (url (current-buffer)))
             (issues-url (redmine-url url :issue ""))
             (bg-buffer (make-instance 'background-buffer :url issues-url)))
        (sleep 1)
        (unwind-protect
            (map 'list #'(lambda (elem)
                           (make-instance
                            'issue
                            :name (plump:text (clss:select "td.subject" elem))
                            :issue-number (parse-integer (plump:text (clss:select "td.id" elem)))
                            :status (plump:text (clss:select "td.status" elem))
                            :assignee (plump:text (clss:select "td.assigned_to" elem))))
                 (clss:select "tr.issue" (document-model bg-buffer)))
          (ffi-buffer-delete bg-buffer)))))))

(defun get-issue-or-current ()
  (let ((url (url (current-buffer))))
    (cond
      ((in-issue-p url)
       (list (in-issue-p url)))
      ((in-project-p url)
       (mapcar #'issue-number (prompt :prompt "Issues"
                                      :sources (list (make-instance 'issue-source)))))
      (t (echo-warning "You're not in a project at the moment!")))))

(defun act-issues (issues action project-p)
  (let ((url (url (current-buffer))))
    (cond
      ((null issues)
       (echo-warning "No issues chosen, not doing anything."))
      ((sera:single issues)
       (buffer-load (redmine-url (url (current-buffer))
                                 :issue (first issues) :action action
                                 :project (if project-p (in-project-p url) nil))))
      (t
       (buffer-load (redmine-url (url (current-buffer))
                                 :issue (first issues) :action action
                                 :project (if project-p (in-project-p url) nil)))
       (dolist (issue issues)
         (make-buffer-focus :url (redmine-url (url (current-buffer))
                                              :issue issue :action action
                                              :project (if project-p (in-project-p url) nil))))))))

(define-command edit-issue (&optional (issues (get-issue-or-current)))
  "Edit the chosen issues or the current one."
  (act-issues issues "edit" nil))

(define-command copy-issue (&optional (issues (uiop:ensure-list
                                               (or (in-issue-p (url (current-buffer)))
                                                   (get-issue-or-current)))))
  "Copy the chosen issues or the current one."
  (act-issues issues "copy" t))

(define-command log-issue (&optional (issues (uiop:ensure-list
                                               (or (in-issue-p (url (current-buffer)))
                                                   (get-issue-or-current)))))
  "Time-log the chose issue or the current one."
  (act-issues issues "time_entries/new" nil))

(define-command toggle-issue-status (&optional (issues (uiop:ensure-list
                                                        (or (in-issue-p (url (current-buffer)))
                                                            (get-issue-or-current)))))
  "Does nothing ATM."
  (echo "Implement me!"))

(define-command new-document ()
  "Create a new document."
  (buffer-load (quri:copy-uri (url (current-buffer))
                              :path (str:concat "/projects/"
                                                (in-project-p (url (current-buffer)))
                                                "/documents/new"))))

(define-command done ()
  "Submit the current form."
  (let ((submit (clss:select "input[type='submit']" (document-model (current-buffer)))))
    (if (sera:single submit)
        (ffi-buffer-evaluate-javascript (current-buffer)
                                        (nyxt/dom:click-element
                                         :nyxt-identifier (get-nyxt-id (elt submit 0))))
        (echo-warning "There are more than 1 submit button on the page, you're on your own :p"))))
