#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(define-generator pcg 32 (stateful-generator)
    ((state #x853c49e6748fea9b :type (unsigned-byte 64))
     (inc #xda3e39cb94b95bdb :type (unsigned-byte 64)))
  (:reseed
   (setf state 0)
   (setf inc (fit-bits 64 (logior 1 (ash seed 1))))
   (pcg-next generator)
   (setf state (fit-bits 64 (+ state seed)))
   (pcg-next generator))
  (:next
   (let ((oldstate state))
     (setf state (fit-bits 64 (+ (fit-bits 64 (* oldstate #x6364136223846793005)) inc)))
     (let ((xord (ash (logxor (ash oldstate -18) oldstate) -27))
           (rot (ash oldstate -59)))
       (fit-bits 32 (logior (ash xord (- rot)) (ash xord (logand (- rot) 31))))))))
