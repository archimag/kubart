;;;; stihiru.lisp

(in-package #:kubart)

(defun load-poem (url dir &key verbose)
  (html:with-parse-html (page url :encoding "cp1251")
    (let* ((index (xpath:find-single-node page "/html/body/index"))
           (title (xpath:find-string index "h1")))
      (when verbose
        (format t "Load ~A (~A)~%" url title))
      (with-open-file (out (make-pathname :directory (pathname-directory dir)
                                          :name title
                                          :type "txt")
                           :direction :output :if-exists :supersede)
        (iter (for br in (xpath:find-list index "div[@class='text']/br"))
              (write-line (string-trim #(#\Newline)
                                       (xtree:text-content (xtree:prev-sibling br)))
                          out))))))
                 
(defun load-all-poems (url target &key verbose (recursive t))
  (ensure-directories-exist target)
  (html:with-parse-html (page url :encoding "cp1251")
    (iter (for node in (xpath:find-list page "//ul/li/a"))
          (load-poem (puri:merge-uris (puri:parse-uri (xtree:attribute-value node "href"))
                                      url)
                     target
                     :verbose verbose))
    (when recursive
      (iter (for node in (xpath:find-list page "//div[@id='bookheader']/a"))
            (let ((title (xtree:text-content node)))
              (when verbose
                (format t "~%Load book ~A~%" title))
              (load-all-poems (puri:merge-uris (puri:parse-uri (xtree:attribute-value node "href"))
                                               url)
                              (merge-pathnames (make-pathname :directory (list :relative title))
                                               target)
                              :recursive nil
                              :verbose verbose))))))
