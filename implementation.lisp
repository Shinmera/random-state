#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

;;;; Integration with the implementation.

(setf (global-generator :system) *random-state*)

(defmethod %make-generator ((type (eql 'random-state)) &key)
  (make-random-state T))

(defmethod seed ((generator random-state))
  #-(or)
  (error "Can't retrieve seed from RANDOM-STATE objects on ~a" (lisp-implementation-type)))

(defmethod reseed ((generator random-state) seed)
  #+sbcl ;; Yikes lol.
  (let ((seeded (sb-ext:seed-random-state seed)))
    (replace (sb-kernel::random-state-state generator)
             (sb-kernel::random-state-state seeded)))
  #-(or sbcl) #- (or sbcl)
  (declare (ignorable generator) (ignore seed))
  (error "Can't reseed RANDOM-STATE objects on ~a" (lisp-implementation-type)))

(defmethod next-byte ((generator random-state))
  (cl:random most-positive-fixnum generator))

(defmethod bits-per-byte ((generator random-state))
  (integer-length most-positive-fixnum))

(defmethod copy ((generator random-state))
  (make-random-state generator))
