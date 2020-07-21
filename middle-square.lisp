#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(defclass middle-square (generator)
  ((bytes :initarg :bytes :writer set-bytes)
   (state :accessor state))
  (:default-initargs
   :bytes 64))

(defmethod reseed ((generator middle-square) &optional new-seed)
  (setf (state generator) new-seed)
  (set-bytes (integer-length new-seed) generator))

(defmethod random-byte ((generator middle-square))
  (let* ((digits (bytes generator))
         (square (expt (state generator) 2))
         (offset (floor (/ (max 0 (- (integer-length square) digits)) 2)))
         (new (ldb (byte digits offset) square)))
    (setf (state generator) new)
    (values new (bytes generator))))
