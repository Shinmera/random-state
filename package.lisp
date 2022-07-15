#|
This file is a part of random-state
(c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:cl-user)
(defpackage #:random-state
  (:nicknames #:org.shirakumo.random-state)
  (:use #:cl)
  ;; generator.lisp
  (:export
   #:global-generator
   #:ensure-generator
   #:list-generator-types
   #:generator
   #:seed
   #:reseed
   #:next-byte
   #:bits-per-byte
   #:copy
   #:make-generator
   #:define-generator
   #:stateful-generator
   #:hash-generator
   #:index
   #:rewind)
  ;; protocol.lisp
  (:export
   #:random-1d
   #:random-2d
   #:random-3d
   #:random-byte
   #:random-bytes
   #:random-sequence
   #:random-unit
   #:random-float
   #:random-int)
  ;; toolkit.lisp
  (:export
   #:hopefully-sufficiently-random-seed)
  ;; * rngs
  (:export
   #:linear-congruence
   #:mersenne-twister-32
   #:mersenne-twister-64
   #:middle-square
   #:pcg
   #:rc4
   #:squirrel
   #:tt800))
