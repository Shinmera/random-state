#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)


(define-generator middle-square 64 (stateful-generator)
    ((bits 64)
     (state 0))
  (:reseed
   (setf state seed)
   (setf bits (integer-length seed)))
  (:next
   (let* ((square (expt state 2))
          (offset (floor (max 0 (- (integer-length square) bits)) 2))
          (new (ldb (byte bits offset) square)))
     (setf state new))))
