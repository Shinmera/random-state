#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(define-generator linear-congruence 64 (stateful-generator)
  ((state 0 :type (unsigned-byte 64))
   (multiplier 6364136223846793005 :type (unsigned-byte 64))
   (increment 1442695040888963407 :type (unsigned-byte 64)))
  (:reseed
   (setf state (mod seed (1- (ash 1 64)))))
  (:next
   (setf state (mod (+ increment (* state multiplier)) (1- (ash 1 64))))))
