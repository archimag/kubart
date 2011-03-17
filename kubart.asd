;;;; kubart.asd

(defsystem kubart
  :depends-on (#:restas-directory-publisher)
  :components ((:module "src"
                        :components
                        ((:file "defmodule")
                         (:file "poems" :depends-on ("defmodule"))
                         (:file "kubart" :depends-on ("poems"))))))