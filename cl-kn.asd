;;;; cl-kn.asd

(asdf:defsystem #:cl-kn
  :description "Common Lisp implementation of Kneser-Ney language Model Smoothing Algolrithm."
  :author "Tianrui Niu niwtr@bupt.edu.cn"
  :license "MIT"
  :depends-on (#:excalibur
               #:let-over-lambda)
  :serial t
  :components ((:file "package")
               (:file "cl-kn")))

