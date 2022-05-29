(in-package #:nyxt-user)

(defvar *debug-autofill*
  (make-instance
   #+nyxt-2 'nyxt:autofill
   #+nyxt-3 'nyxt/autofill-mode:autofill
   :name "Debug"
   :fill (lambda ()
           (nyxt:peval (setf (ps:@ document active-element value) ""))
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
            (nyxt::system-information)))))

#+nyxt-3
(nyxt::define-command-global report-bug ()
  "Report the bug on Nyxt GitHub, filling all the necessary information in the process."
  (let* ((title (prompt1
                  :prompt "Title of the issue"
                  :sources (list (make-instance 'prompter:raw-source))))
         (buffer (make-buffer-focus
                  :url (quri:uri (format nil "https://github.com/atlas-engineer/nyxt/issues/new?&template=bug_report.md&title=~a"
                                         title)))))
    (nyxt:once-on (buffer-loaded-hook buffer)
        (buffer)
      (nyxt:peval (ps:chain (nyxt/ps:qs document "#issue_body") (focus)))
      (%paste :input-text (funcall (nyxt/autofill-mode:autofill-fill *debug-autofill*))))))

(define-command-global eval-expression ()
  "Prompt for the expression and evaluate it, echoing result to the `message-area'."
  (let ((expression-string
          ;; Read an arbitrary expression. No error checking, though.
          (first (prompt :prompt "Expression to evaluate"
                         :sources (list (make-instance 'prompter:raw-source))))))
    ;; Message the evaluation result to the message-area down below.
    (echo "~S" (eval (read-from-string expression-string)))))

#+nyxt-3
(nyxt::define-panel-global hsplit (&key (buffer (id (current-buffer))))
    (panel "Duplicate panel" :right)
  "Duplicate the current buffer URL in the panel buffer on the right.

A poor man's hsplit :)"
  (progn
    (ffi-window-set-panel-buffer-width (current-window) panel 750)
    (run-thread "URL loader"
      (buffer-load (url (nyxt::buffers-get buffer)) :buffer panel))
    ""))

#+nyxt-3
(define-command-global close-all-panels ()
  "Close all the panel buffers there are."
  (when (panel-buffers-right (current-window))
    (delete-panel-buffer :window (current-window) :panels (panel-buffers-right (current-window))))
  (when (panel-buffers-left (current-window))
    (delete-panel-buffer :window (current-window) :panels (panel-buffers-left (current-window)))))

#+nyxt-3
(define-command-global hsplit ()
  "Based on `hsplit-panel' above."
  (if (panel-buffers-right (current-window))
      (close-all-panels)
      (hsplit-panel)))
