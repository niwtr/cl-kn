;;;; cl-kn.lisp

(in-package #:cl-kn)

;;; "cl-kn" goes here. Hacks and glory await!




(defun ngrams-generator (n seq)
  "generate trigrams piece by piece."
  (let ((wseq seq))
    (lambda ()
      (lett (ngram (firstn n wseq))
        (when (= (length ngram) n)
          (setf wseq (cdr wseq))
          ngram)))))


(defun bigram-generator (seq)
  (ngrams-generator 2 seq))
(defun unigram-generator (seq)
  (ngrams-generator 1 seq))
(defun trigram-generator (seq)
  (ngrams-generator 3 seq))


(defun wordstream->dict (ss &key (fn #'identity))
  (lett (hash (make-hash-table :test #'equal :size 1500000))
    (loop for word = (funcall ss)
       while word do
         (incf (gethash (funcall fn word) hash 0)))
    hash))

(defun incfdict (key dict val)
  (incf (gethash key dict 0) val))

(defun indict (key dict)
  (gethash key dict))


(defun [] (word dict)
  (gethash word dict 0))


(defun ngrams-generator (n seq)
  "generate trigrams piece by piece."
  (let ((wseq seq))
    (lambda ()
      (lett (ngram (firstn n wseq))
            (when (= (length ngram) n)
              (setf wseq (cdr wseq))
              ngram)))))


(defun bigram-generator (seq)
  (ngrams-generator 2 seq))
(defun unigram-generator (seq)
  (ngrams-generator 1 seq))
(defun trigram-generator (seq)
  (ngrams-generator 3 seq))


(defun kn-smooth-establish (kernel training-data &optional (d 0.75))
  (funcall kernel :establish training-data d))
(defun kn-smooth-clear (kernel)
  (funcall kernel :clear))
(defun kn-smooth-generate-prober (kernel)
  (funcall kernel :generate-prober))


(defun kn-smooth ()
  ;;corp-lst: a lst of segmented strs.
  (let* ((d)
         (triglist);; (trigram-generator corp-lst))
         (trigdict);; (wordstream->dict triglist))
         (bigdict (make-hash-table :test #'equal :size 1000000))
         (unigdict (make-hash-table :test #'equal :size 1000000))
         (?w1w2/type (make-hash-table :test #'equal :size 1000000))
         (w0w1?/type (make-hash-table :test #'equal :size 1000000))
         (?w1?/type (make-hash-table :test #'equal :size 1000000))
         (?w2/type (make-hash-table :test #'equal :size 1000000))
         (w1?/type (make-hash-table :test #'equal :size 1000000)))

    (dlambda
     (:clear nil
             (mapcar #'clrhash
                     `(,trigdict ,bigdict ,unigdict ,?w1w2/type ,w0w1?/type
                                 ,?w1?/type ,?w2/type ,w1?/type))
             (setf triglist nil))
     (:establish (corp-lst &optional (_d 0.75))
                 (setf triglist (trigram-generator corp-lst))
                 (setf trigdict (wordstream->dict triglist))
                 (setf d _d)
                 (maphash (lambda (key val)
                            (let*
                                ((w0w1w2 key)
                                 (w0w1 (butlast key))
                                 (w1w2 (cdr key))
                                 (w0 (list (first key)))
                                 (w1 (list (second key))))
                              (setf (gethash w0 unigdict) 1) ;;collect |v|
                              (incfdict w0w1 bigdict val)
                              (incfdict w1w2 ?w1w2/type 1)
                              (incfdict w0w1 w0w1?/type 1)
                              (incfdict w1   ?w1?/type 1)))
                          trigdict)
                 (maphash (lambda (key val)
                            (let*
                                ((w1w2 key)
                                 (w1  (list (first key)))
                                 (w2  (cdr key)))
                              (incfdict w1 w1?/type 1)
                              (incfdict w2 ?w2/type 1)))
                          bigdict)
                 (format t "Successfully trained KN model.~%")
                 (format t "Trigram dict size: ~D~%" (hash-table-size trigdict))
                 (format t "Bigram  dict size: ~D~%" (hash-table-size bigdict))
                 (format t "Unigram dict size: ~D~%" (hash-table-size unigdict)))

     (:generate-prober nil
                     (lambda (trig)
                       (let
                           ((w0w1w2 trig)
                            (w0w1 (butlast trig))
                            (w1w2 (cdr trig))
                            (w2 (last trig))
                            (w1 (list (second trig))))
                         (labels ((alpha3 (trig)
                                    (/ (- ([] w0w1w2 trigdict) d) ;; c(w0w1w2)
                                       ([] w0w1 bigdict))) ;;c(w0w1)
                                  (gamma3 (trig)
                                    (*
                                     (/ d ([] w0w1 bigdict)) ;;c(w0w1)
                                     ([] w0w1 w0w1?/type)));;N1+(w0w1*)
                                  (gamma3/cont (trig)
                                    (*
                                     (/ d ([] w1 ?w1?/type)) ;;N1+(w0w1*)
                                     ([] w0w1 w0w1?/type))) ;;N1+(*w1*)
                                  (alpha2 (big)
                                    (max
                                     (/ (- ([] w1w2 ?w1w2/type) d) ;;N1+(*w2)
                                        ([] w1 ?w1?/type))
                                     0));; N1+(*w1*)
                                  (gamma2 (big)
                                    (*
                                     (/ d ([] w1 ?w1?/type)) ;;N1+(*w1*)
                                     ([] w1 w1?/type))) ;;N1+(w1*)
                                  ;;TODO modify kn1
                                  (kn1 (unig)
                                    (+
                                     (/ ([] unig ?w2/type) ;;N1+(*w2)
                                        (hash-table-count bigdict)) ;; N1+(**)
                                     (/ d (hash-table-count unigdict))))
                                  (kn2 (big)
                                    (if (indict w1 ?w1?/type)
                                        (progn
                                          (+ (alpha2 big)
                                             (* (gamma2 big)  ;;unhit big.
                                                (kn1 (cdr big))))) ;;kn1.
                                        (progn
                                          (kn1 (cdr big)))))

                                  (kn3 (trig)
                                    (cond
                                      ((indict trig trigdict)
                                       (+ (alpha3 trig) (* (gamma3 trig) (kn2 w1w2)))) ;;hit 3
                                      ((indict w0w1 bigdict) ;;\hit 3 hit w0w1
                                       (* (gamma3 trig) (kn2 w1w2)))
                                      ((indict w1 ?w1?/type) ;;\hit 3 \hit w0w1 hit *w1*
                                       (* 1 (kn2 w1w2)))
                                      (t (kn1 (last trig))))))
                           ;;(kn3 trig))))))))
                           (- (log 10 (kn3 trig))))))))))
