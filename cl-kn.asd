;;;; cl-kn.asd

(asdf:defsystem #:cl-kn
  :description "Common Lisp implementation of Kneser-Ney language Model Smoothing Algolrithm."
  :author "Tianrui Niu niwtr@bupt.edu.cn"
  :license "MIT"
  :depends-on (#:excalibur)
  :serial t
  :components ((:file "package")
               (:file "cl-kn")))

