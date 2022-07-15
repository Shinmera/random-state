#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(define-generator rc4 8 (stateful-generator)
    ((index1 0 :type (unsigned-byte 8))
     (index2 0 :type (unsigned-byte 8))
     (state (make-array 256 :element-type '(unsigned-byte 8)) :type (simple-array (unsigned-byte 8) (256))))
  (:reseed
   (loop for i from 0 below 256
         do (setf (aref state i) i))
   (setf index1 0)
   (setf index2 0)
   (let ((seed-length (integer-length seed)))
     (loop for i of-type (integer 0 256) from 0 below 256
           for j of-type (integer 0 256) = 0
           then (mod (+ j
                        (aref state i)
                        (ldb (byte 8 (mod (* 8 i) seed-length)) seed))
                     256)
           do (rotatef (aref state i)
                       (aref state j)))))
  (:next
   (incfmod index1 256)
   (incfmod index2 256 (aref state index1))
   (rotatef (aref state index1)
            (aref state index2))
   (aref state
         (mod
          (+ (aref state index1)
             (aref state index2))
          256))))
