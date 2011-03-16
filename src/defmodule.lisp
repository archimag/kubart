;;;; defmodule.lisp

(restas:define-module #:kubart
  (:use #:cl #:iter))

(in-package #:kubart)

(defparameter *poems-directory* #P"/var/kubart/poems/")

(defparameter *basedir*
  (make-pathname :directory
                 (pathname-directory
                  (asdf:component-pathname (asdf:find-system '#:kubart)))))

(defun kubart-pathaname (relpath)
  (merge-pathnames relpath *basedir*))

(closure-template:compile-template :common-lisp-backend
                                   (kubart-pathaname "src/kubart.tmpl"))
                                    
(defmethod restas:initialize-module-instance ((module (eql #.*package*)) context)
  (restas:with-context context
    (setf (restas:context-symbol-value (restas:submodule-context (restas:find-submodule '-poems-))
                                       'restas.directory-publisher:*directory*)
          *poems-directory*)))