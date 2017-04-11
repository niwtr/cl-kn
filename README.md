# CL-KN

A Common Lisp implementation of trigram Kneser-Ney language Model Smoothing Algorithm. 
This software gains the features below:

1. Fast. It's optimized for fast use.
2. Robust. The probability is scaled into -log10 so it won't ZERO your sentence probabilities.
3. Easy to use. Just train the n-gram model and prob.

# Usage
Dependency:
1. Let-Over-Lambda.
2. Excalibur (My personal Lib.)

```lisp
(defparameter kernel (kn-smooth)) ;;generate kernel.
(kn-smooth-establish kernel *training-data*) ;;where *training-data* is a list of strings (word segments).
(defparameter prob (kn-smooth-generate-prober kernel)) ;;generate prober
(funcall prob '("我" "十分" "高兴")) ;;prob the trigram.
```
# About 
This software is dedicated to my girlfriend, Li. I love her so much.

License: MIT. Use this wherever you want. :)

Hacks and glory awaits!

Tianrui Niu
