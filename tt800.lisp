#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

;; Adapted from
;;   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/VERSIONS/C-LANG/tt800.c

(define-generator tt800 32 (stateful-generator)
    ((magic (barr 32 0 #x8ebfd028) :type (simple-array (unsigned-byte 32) (2)))
     (n 25 :type (unsigned-byte 8))
     (m 7 :type (unsigned-byte 8))
     (index 0 :type (unsigned-byte 64))
     (matrix (make-array 25 :element-type `(unsigned-byte 32)) :type (simple-array (unsigned-byte 32) (25))))
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
         (update 32 result logxor (logand (ash result 7) #x2b5b2500))
         (update 32 result logxor (logand (ash result 15) #xdb8b0000))
         (update 32 result logxor (logand (ash result -16) #xffffffff))
         result)))))
