#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

;; Adapted from
;;   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/VERSIONS/C-LANG/tt800.c

(define-generator tt800 32 (stateful-generator)
    ((magic (barr 32 0 #x8ebfd028))
     (shiftops #((  7 #x2b5b2500)
                 ( 15 #xdb8b0000)
                 (-16 #xffffffff)))
     (n 25)
     (m 7)
     (index 0)
     (matrix NIL))
  (:reseed
   (setf matrix (32bit-seed-array n seed)))
  (:next
   (let ((i 0))
     (flet ((matrix (n) (aref matrix n))
            (magic (n) (aref magic n)))
       (declare (inline matrix magic))
       (when (= (the integer index) n)
         (loop while (< i (- n m))
               do (setf (aref matrix i)
                        (logxor (matrix (+ i m))
                                (ash (matrix i) -1)
                                (magic (mod (matrix i) 2))))
                  (incf i))
         (loop while (< i n)
               do (setf (aref matrix i)
                        (logxor (matrix (+ i (- m n)))
                                (ash (matrix i) -1)
                                (magic (mod (matrix i) 2))))
                  (incf i))
         (setf index 0))
       (let ((result (matrix index)))
         (declare (type (unsigned-byte 32) result))
         (incf index)
         (loop for (shift mask) across shiftops
               do (setf result (logxor result (logand (ash result (the (signed-byte 6) shift))
                                                      (the (unsigned-byte 32) mask)))))
         result)))))
