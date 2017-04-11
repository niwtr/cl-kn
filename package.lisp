;;;; package.lisp

(defpackage #:cl-kn
  (:use #:cl #:cl-user #:common-lisp #:excalibur)
  (:import-from #:let-over-lambda dlambda)
  (:export
   #:kn-smooth
   #:kn-smooth-clear
   #:kn-smooth-establish
   #:kn-smooth-generate-prober
  ))



