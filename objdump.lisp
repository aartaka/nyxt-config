(in-package #:nyxt-user)

(define-internal-page-command-global objdump (&key (file (uiop:native-namestring
                                                          (prompt1 :prompt "File to disassemble"
                                                                   :input (uiop:native-namestring (uiop:getcwd))
                                                                   :sources 'nyxt/mode/file-manager:file-source))))
    (buffer (format nil "Objdump of ~a" file))
  "Show disassembly of code sections and contents of data sections in FILE."
  (spinneret:with-html-string
    (let* ((disassembly
             (uiop:run-program (list "objdump" "--demangle" "--debugging" "--disassemble"
                                     "--line-numbers" "--source" "--visualize-jumps" "--wide" file)
                               :output '(:string :stripped t)))
           (lines (member-if (lambda (elem) (uiop:string-prefix-p "Disassembly" elem))
                             (mapcar #'str:trim (str:split "

" disassembly :omit-nulls t))))
           (sections (mapcar
                      (lambda (string)
                        (multiple-value-bind (start end starts ends)
                            (ppcre:scan "(\\d+)\\s*([^\\s]*).*" string)
                          (subseq string (elt starts 1) (elt ends 1))))
                      (remove-if-not
                       (lambda (str) (digit-char-p (elt str 0)))
                       (remove-if #'uiop:emptyp
                                  (mapcar #'str:trim
                                          (serapeum:lines
                                           (uiop:run-program (list "objdump" "-h" file)
                                                             :output '(:string :stripped t))))))))
           (code-sections (loop for (section code) on lines by #'cddr
                                collect (if (uiop:string-prefix-p "Disassembly of section " section)
                                            (serapeum:slice section 23 -1)
                                            section)))
           (data-sections (set-difference sections code-sections :test #'string-equal)))
      (loop for (section code) on lines by #'cddr
            collect (:nsection
                      :id (prini-to-string (new-id))
                      :title (if (uiop:string-prefix-p "Disassembly of section " section)
                                 (subseq section 23)
                                 section)
                      (:pre code)))
      (loop for data in data-sections
            collect (:nsection
                      :id (prini-to-string (new-id))
                      :title data
                      (:pre (cadr (mapcar
                                   #'str:trim
                                   (str:split "

" (uiop:run-program (list "objdump" "--section" data "--full-contents" file)
                    :output '(:string :stripped t))
:omit-nulls t)))))))))
