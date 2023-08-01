;; Could be an extension someday.
(nyxt:define-package :nx-github-mode
  (:documentation "Mode with GitHub-related commands."))
(in-package :nx-github-mode)

(nyxt:define-mode github-mode ()
  "Manage Nyxt GitHub repository with convenient keybindings."
  ((glyph "γ")
   (keyscheme-map
    (define-keyscheme-map "github-mode" ()
      keyscheme:emacs
      (list
       "C-c C-c" 'approve-pull-request
       "C-c C-m" 'new-feature-request
       "C-c C-k" 'report-bug
       "C-c C-r" 'review
       "C-c C-0" 'notifications)))))

(define-command notifications ()
  (let* ((notification-links (clss:select "a[href^=\"https://github.com/notifications\"]"
                               (document-model (current-buffer))))
         (back-to-notifications
           (unless (uiop:emptyp notification-links)
             (find-if (lambda (l) (search "Back to notifications" (nyxt/dom:body l)))
                      notification-links))))
    (if back-to-notifications
        (nyxt/dom:click-element back-to-notifications)
        (buffer-load "https://github.com/notifications?query=reason:assign%20reason:mention%20reason:review-requested%20reason:team-mention%20reason:ci-activity"))))

(define-command nyxt ()
  (buffer-load "https://github.com/atlas-engineer/nyxt"))

(defun debug-autofill ()
  (ps-eval
   (setf (ps:@ document active-element value) ""))
  (format
   nil "**Describe the bug**

**Precise recipe to reproduce the issue**

For website-specific issues:
Can you reproduce this issue with Epiphany / GNOME Web (https://wiki.gnome.org/Apps/Web)?

**Information**
- OS name+version: GuixSD
```sh
$ guix describe
~a
```
- Graphics card and driver: Intel UHD 620, `i915`
``` sh
$ lspci -v
...
00:02.0 VGA compatible controller: Intel Corporation UHD Graphics (rev 01) (prog-if 00 [VGA controller])
	Subsystem: Lenovo Device 5089
	Flags: bus master, fast devsel, latency 0, IRQ 165
	Memory at 601c000000 (64-bit, non-prefetchable) [size=16M]
	Memory at 4000000000 (64-bit, prefetchable) [size=256M]
	I/O ports at 3000 [size=64]
	Expansion ROM at 000c0000 [virtual] [disabled] [size=128K]
	Capabilities: <access denied>
	Kernel driver in use: i915
	Kernel modules: i915
...
```
- Desktop environment / Window manager name+version: StumpWM 20.11
- How you installed Nyxt (Guix pack, package manager, build from source): `guix package -f nyxt.scm`
- Information from `show-system-information`:
```
~a
```

**Output when started from a shell** "
   (uiop:run-program "guix describe"
                     :output '(:string :stripped t))
   (nyxt::system-information)))

(define-command report-bug ()
  "Report the bug on Nyxt GitHub, filling all the necessary information in the process."
  (let* ((title (prompt1
                 :prompt "Title of the issue"
                 :sources (list (make-instance 'prompter:raw-source))))
         (buffer (make-buffer-focus
                  :url (quri:uri (format nil "https://github.com/atlas-engineer/nyxt/issues/new?&template=bug_report.md&title=~a"
                                         title)))))
    (hooks:once-on (buffer-loaded-hook buffer)
        (buffer)
      (ps-eval
       (ps:chain (nyxt/ps:qs document "#issue_body") (focus)))
      (ffi-buffer-paste buffer (debug-autofill)))))

(define-command new-feature-request ()
  "Open a new feature request in Nyxt repo."
  (let* ((title (prompt1
                 :prompt "Title of the issue"
                 :sources (list (make-instance 'prompter:raw-source))))
         (buffer (make-buffer-focus
                  :url (quri:uri (format nil "https://github.com/atlas-engineer/nyxt/issues/new?assignees=&labels=feature&template=feature_request.md&title=~a"
                                         title)))))
    (hooks:once-on (buffer-loaded-hook buffer)
        (buffer)
      (ps-eval
         (ps:chain (nyxt/ps:qs document "#issue_body") (focus))))))

(define-command review ()
  "Open the file diffing tab of the pull request."
  (let* ((url (url (current-buffer)))
         (files-url (quri:copy-uri
                     url
                     :path (str:concat (string-right-trim "/" (quri:uri-path url))
                                       "/files"))))
    (unless (or (search "/files" (render-url url))
                (string/= "github.com" (quri:uri-domain url)))
      (buffer-load files-url))))

(define-command approve-pull-request ()
  "Approve the pull request currently open."
  (review)
  (hooks:wait-on (buffer-loaded-hook (current-buffer))
      buffer
    ;; Make sure Nyxt DOM is fresh.
    (update-document-model :buffer buffer)
    (flet ((sel (selector)
             (let ((result (clss:select selector  (document-model buffer))))
               (unless (uiop:emptyp result)
                 (elt result 0)))))
      ;; Nyxt/DOM already has lots of things, so why not use them?
      (nyxt/dom:toggle-details-element (sel "#review-changes-modal"))
      (nyxt/dom:click-element (sel "input[type=radio][value=approve]"))
      (nyxt/dom:click-element (sel "button[type=submit]")))))

(define-command done ()
  (let* ((button (elt (clss:select "button[type=\"submit\"][title=\"Done\"],
button[type=\"submit\"][aria-label=\"Done\"]"
                                   (document-model (current-buffer))) 0)))
    (nyxt/dom:click-element button)))

(define-auto-rule '(match-domain "github.com")
  :included '(github-mode))
