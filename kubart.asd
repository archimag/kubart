;;;; kubart.asd

(defsystem kubart
  :depends-on (#:restas-directory-publisher)
  :components ((:module "src"
                        :components
                        ((:file "defmodule")
                         (:file "kubart" :depends-on ("defmodule"))))))