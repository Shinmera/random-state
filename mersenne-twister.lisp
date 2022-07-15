#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

;; Adapted from 
;;   http://www.acclab.helsinki.fi/~knordlun/mc/mt19937.c
;; and
;;   http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/VERSIONS/C-LANG/mt19937-64.c
;; respectively.

(defstruct (mersenne-twister
            (:include stateful-generator)
            (:constructor NIL)
            (:predicate NIL))
  (index 0 :type (unsigned-byte 64)))

(defmacro %inner-mersenne-twister (bytes n m upper lower matrix magic &rest shiftops)
  `(let ((i 0)
         (n ,n)
         (m ,m)
         (upper ,upper)
         (lower ,lower)
         (matrix ,matrix)
         (magic ,magic))
     (declare (optimize speed)
              (type (simple-array (unsigned-byte ,bytes)) matrix magic)
              (type (unsigned-byte 16) n m i))
     (flet ((magic (i) (aref magic i))
            (matrix (i) (aref matrix i)))
       (declare (inline magic matrix))
       (when (= (mersenne-twister-index generator) n)
         (loop while (< i (- n m))
               do (let ((x (logior (logand (matrix i) upper)
                                   (logand (matrix (1+ i)) lower))))
                    (setf (aref matrix i)
                          (logxor (matrix (+ i m))
                                  (ash x -1)
                                  (magic (mod x 2)))))
                  (incf i))
         (loop while (< i (1- n))
               do (let ((x (logior (logand (matrix i) upper)
                                   (logand (matrix (1+ i)) lower))))
                    (setf (aref matrix i)
                          (logxor (matrix (+ i (- m n)))
                                  (ash x -1)
                                  (magic (mod x 2)))))
                  (incf i))
         (setf (mersenne-twister-index generator) 0))
       (let ((result (matrix (mersenne-twister-index generator))))
         (declare (type (unsigned-byte ,bytes) result))
         (setf (mersenne-twister-index generator) (logand (1+ (mersenne-twister-index generator)) (1- (ash 1 64))))
         ,@(loop for (shift mask) in shiftops
                 collect `(setf result (logxor result
                                               (logand (ash (the (unsigned-byte ,bytes) result)
                                                            ,shift)
                                                       ,mask))))
         result))))

(define-generator mersenne-twister-32 32 (mersenne-twister (index 624))
    ((upper #x80000000 :type (unsigned-byte 32))
     (lower #x7fffffff :type (unsigned-byte 32))
     (magic (barr 32 0 #x9908b0df) :type (simple-array (unsigned-byte 32) (2)))
     (matrix (make-array 624 :element-type `(unsigned-byte 32)) :type (simple-array (unsigned-byte 32) (624))))
  (:reseed
   (setf matrix (32bit-seed-array 624 seed))
   (setf index 624))
  (:next
   (%inner-mersenne-twister 32 624 397 upper lower matrix magic
                            (-11 #xFFFFFFFF)
                            (  7 #x9D2C5680)
                            ( 15 #xEFC60000)
                            (-18 #xFFFFFFFF))))

(define-generator mersenne-twister-64 64 (mersenne-twister (index 312))
    ((upper #xFFFFFFFF80000000 :type (unsigned-byte 64))
     (lower #x000000007FFFFFFF :type (unsigned-byte 64))
     (magic (barr 64 0 #xB5026F5AA96619E9) :type (simple-array (unsigned-byte 64) (2)))
     (matrix (make-array 312 :element-type `(unsigned-byte 32)) :type (simple-array (unsigned-byte 64) (312))))
  (:reseed
   (setf matrix (64bit-seed-array 312 seed))
   (setf index 312))
  (:next
   (%inner-mersenne-twister 64 312 156 upper lower matrix magic
                            (-29 #x5555555555555555)
                            ( 17 #x71D67FFFEDA60000)
                            ( 37 #xFFF7EEE000000000)
                            (-43 #xFFFFFFFFFFFFFFFF))))
