(in-package #:nyxt-user)

;; I'm definining a new scheme to redirect PDF requests to. What it does is:
;; - Get the original file.
;; - Save it to disk.
;; - Run pdftotext over it.
;; - Display pdftotext output in a nice <pre> tag.
(define-internal-scheme "unpdf"
    (lambda (url buffer)
      (let* ((url (quri:uri url))
             (original-url (quri:uri-path url))
             (original-content (dex:get original-url :force-binary t)))
        (uiop:with-temporary-file (:pathname path :type "pdf" :keep t)
          (log:debug "Temp file for ~a is ~a" url path)
          (alexandria:write-byte-vector-into-file
           (coerce original-content '(vector (unsigned-byte 8))) path :if-exists :supersede)
          (let ((text (uiop:run-program `("pdftotext" ,(uiop:native-namestring path) "-")
                                        :output '(:string :stripped t))))
            (spinneret:with-html-string
              (:head (:style (style buffer)))
              (:pre (or text "")))))))
  :local-p t)

(define-command-global unpdf-download-this ()
  "A helper for unpdf: pages to download the original PDF to the regular destination.

Unpdf redirects all requests, even those that you need to read
elsewhere, thus I need this command."
  (let* ((buffer (current-buffer))
         (url (url buffer)))
    (if (string= "unpdf" (quri:uri-scheme url))
        (ffi-buffer-download buffer (quri:uri-path url))
        ;; I need to turn it into a mode someday...
        (echo-warning "This command is for unpdf: pages only, it's useless elsewhere!"))))

(defun redirect-pdf (request-data)
  (if (uiop:string-prefix-p "application/pdf" (mime-type request-data))
      ;; I should somehow prompt about downloading instead...
      (progn
        (echo "Redirecting to the unpdf URL...")
        (make-buffer-focus :url (quri:uri (str:concat "unpdf:" (render-url (url request-data)))))
        ;; Return nil to prevent Nyxt from downloading this PDF.
        nil)
      request-data))

(define-configuration web-buffer
  ((request-resource-hook (hooks:add-hook %slot-value% 'redirect-pdf))))
