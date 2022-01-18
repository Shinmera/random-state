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

(declaim (ftype (function (T) fixnum) index))

(defclass mersenne-twister (generator)
  ((n :initarg :n :reader n)
   (m :initarg :m :reader m)
   (upper :initarg :upper :reader upper)
   (lower :initarg :lower :reader lower)
   (matrix :initarg :matrix :reader matrix :writer set-matrix)
   (index :initarg :index :accessor index)
   (magic :initarg :magic :reader magic)
   (shiftops :initarg :shiftops :reader shiftops)))

(defmethod reseed :after ((generator mersenne-twister) &optional new-seed)
  (declare (ignore new-seed))
  (setf (index generator) (n generator)))

(defmacro %inner-mersenne-twister (bytes)
  `(let ((i 0)
         (n (n generator))
         (m (m generator))
         (upper (upper generator))
         (lower (lower generator))
         (matrix (matrix generator))
         (magic (magic generator))
         (shiftops (shiftops generator)))
     (declare (optimize speed)
              (ftype (function (mersenne-twister) (unsigned-byte 16)) index)
              (type (simple-array (unsigned-byte ,bytes)) matrix magic)
              (type (unsigned-byte 16) n m i))
     (flet ((magic (i) (aref magic i))
            (matrix (i) (aref matrix i)))
       (declare (inline magic matrix))
       (when (= (the integer (index generator)) n)
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
         (setf (index generator) 0))
       (let ((result (matrix (index generator))))
         (declare (type (unsigned-byte ,bytes) result))
         (setf (index generator) (the fixnum (1+ (index generator))))
         (loop for (shift mask) across shiftops
               do (setf result (logxor result
                                       (logand (ash (the (unsigned-byte ,bytes) result)
                                                    (the (signed-byte 16) shift))
                                               (the (unsigned-byte ,bytes) mask)))))
         result))))

(defclass mersenne-twister-32 (mersenne-twister)
  ((bytes :initform 32))
  (:default-initargs
   :n 624
   :m 397
   :upper #x80000000
   :lower #x7fffffff
   :magic (barr 32 0 #x9908b0df)
   :shiftops #((-11 #xFFFFFFFF)
               (  7 #x9D2C5680)
               ( 15 #xEFC60000)
               (-18 #xFFFFFFFF))))

(defmethod reseed ((generator mersenne-twister-32) &optional new-seed)
  (set-matrix (32bit-seed-array (n generator) new-seed) generator))

(defmethod random-byte ((generator mersenne-twister-32))
  (%inner-mersenne-twister 32))

(defclass mersenne-twister-64 (mersenne-twister)
  ((bytes :initform 64))
  (:default-initargs
   :n 312
   :m 156
   :upper #xFFFFFFFF80000000
   :lower #x000000007FFFFFFF
   :magic (barr 64 0 #xB5026F5AA96619E9)
   :shiftops #1A((-29 #x5555555555555555)
                 ( 17 #x71D67FFFEDA60000)
                 ( 37 #xFFF7EEE000000000)
                 (-43 #xFFFFFFFFFFFFFFFF))))

(defmethod reseed ((generator mersenne-twister-64) &optional new-seed)
  (set-matrix (64bit-seed-array (n generator) new-seed) generator))

(defmethod random-byte ((generator mersenne-twister-64))
  (%inner-mersenne-twister 64))
