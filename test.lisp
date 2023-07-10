(in-package #:cl-user)
(defpackage #:org.shirakumo.random-state.test
  (:use #:cl #:parachute)
  (:local-nicknames
   (#:random #:org.shirakumo.random-state)))
(in-package #:org.shirakumo.random-state.test)

(define-test random-state)

(defun draw (n generator &optional (arg 1.0))
  (let ((array (make-array n)))
    (dotimes (i n array)
      (setf (svref array i) (random:random arg generator)))))

(defun test-clean-copying (generator)
  (is equalp
      (draw 10 (random:copy generator))
      (draw 10 generator)
      "Testing ~a" generator))

(defmacro define-default-rng-test (type &body body)
  `(define-test ,type
     :parent random-state
     ,@body
     (test-clean-copying (random:make-generator ',type))))

(define-default-rng-test random:squirrel)
(define-default-rng-test random:kiss11)
(define-default-rng-test random:tt800)
(define-default-rng-test random:rc4)
(define-default-rng-test random:pcg)
(define-default-rng-test random:middle-square)
(define-default-rng-test random:mersenne-twister-64)
(define-default-rng-test random:mersenne-twister-32)
(define-default-rng-test random:linear-congruence)
(define-default-rng-test random:xorshift-32)
(define-default-rng-test random:xorshift-64)
(define-default-rng-test random:xorshift-128)
(define-default-rng-test random:xorwow)
(define-default-rng-test random:xorshift-64*)
(define-default-rng-test random:xorshift-1024*)
(define-default-rng-test random:xorshift-128+)
(define-default-rng-test random:xoshiro-128**)
(define-default-rng-test random:xoshiro-128+)
(define-default-rng-test random:xoshiro-256**)
(define-default-rng-test random:xoshiro-256+)
