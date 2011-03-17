;;;; defmodule.lisp

(restas:define-module #:kubart
  (:use #:cl #:iter))

(restas:define-module #:kubart.poems
  (:use #:cl #:iter))

(in-package #:kubart)

(defparameter *basedir*
  (make-pathname :directory
                 (pathname-directory
                  (asdf:component-pathname (asdf:find-system '#:kubart)))))

(defun kubart-pathaname (relpath)
  (merge-pathnames relpath *basedir*))

(closure-template:compile-template :common-lisp-backend
                                   (kubart-pathaname "src/kubart.tmpl"))
                                    
