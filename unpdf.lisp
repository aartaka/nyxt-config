(in-package #:nyxt-user)

(define-internal-scheme "unpdf"
    (lambda (url buffer)
      (let* ((url (quri:uri url))
             (original-url (quri:uri-path url))
             (original-content (dex:get original-url :force-binary t)))
        (echo "Content is ~a" original-content)
        (uiop:with-temporary-file (:pathname path :type "pdf" :keep t)
          (echo "Temp file is ~a" path)
          (alexandria:write-byte-vector-into-file
           (coerce original-content '(vector (unsigned-byte 8))) path :if-exists :supersede)
          (let ((text (uiop:run-program `("pdftotext" ,(uiop:native-namestring path) "-")
                                        :output '(:string :stripped t))))
            (spinneret:with-html-string
              (:head (:style (style buffer)))
              (:pre (or text "")))))))
  :local-p t)

(defun redirect-pdf (request-data)
  (echo "MIME type is ~a" (mime-type request-data))
  (if (uiop:string-prefix-p "application/pdf" (mime-type request-data))
      (progn
        (echo "Redirecting to the unpdf URL...")
        (make-buffer-focus :url (quri:uri (str:concat "unpdf:" (render-url (url request-data)))))
        nil)
      request-data))

(push 'redirect-pdf *request-resource-handlers*)
