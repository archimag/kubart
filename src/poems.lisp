;;;; poems.lisp


(in-package #:kubart.poems)

(defparameter *poems-directory* #P"/var/kubart/poems/")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; drawer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass poem-drawer () ())

(defmethod restas:render-object ((drawer poem-drawer) (poem pathname))
  (setf (hunchentoot:content-type*) "text/html; charset=utf-8")
  (kubart.view:poem-page
   (list :title (pathname-name poem)
         :poem (iter (for line in-file poem using #'read-line)
                     (collect line)))))

(defmethod restas:render-object ((drawer poem-drawer) (dir cons))
  (kubart.view:category-page dir))
                             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  routes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun category-pathname (category)
  (if category
      (merge-pathnames (make-pathname :directory (list :relative category))
                       *poems-directory*)
      *poems-directory*))

(defun poem-pathname (poem &optional category)
  (make-pathname :name poem
                 :type "txt"
                 :directory (pathname-directory (category-pathname category))))

(defun all-poems (category)
  (iter (for item in (fad:list-directory (category-pathname category)))
        (when (string-equal "txt" (pathname-type item))
          (collect (list :name (pathname-name item)
                         :href (if category
                                   (restas:genurl 'view-category-poem
                                                  :category category
                                                  :poem (pathname-name item))
                                   (restas:genurl 'view-poem
                                                  :poem (pathname-name item))))))))

(defun list-poem-categories (&optional category)
  (iter (for item in (fad:list-directory *poems-directory*))
        (when (fad:directory-pathname-p item)
          (collect (let ((name (car (last (pathname-directory item)))))
                     (list :name name
                           :href (if (not (and category (string= name category)))
                                     (restas:genurl 'view-category :category name))
                           :poems (if (and category (string= name category))
                                      (all-poems category))))))))
  

(restas:define-route view-all-category ("")
  (list :title "Стихи Марии Петелиной"
        :poems (all-poems nil)
        :categories (list-poem-categories)))
        

(restas:define-route view-category (":category/")
  (list :title category
        :categories (list* (list :name "Произведения, не вошедшие в рубрики"
                                 :href (restas:genurl 'view-all-category))
                           (list-poem-categories category))))

  
(restas:define-route view-poem (":poem")
  (poem-pathname poem))

(restas:define-route view-category-poem (":category/:poem")
  (poem-pathname poem category))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  initialize
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmethod restas:initialize-module-instance ((module (eql #.*package*)) context)
  (setf (restas:context-symbol-value context '*default-render-method*)
        (make-instance 'poem-drawer)))
