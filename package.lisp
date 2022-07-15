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
   #:generator
   #:seed
   #:reseed
   #:next-byte
   #:bits-per-byte
   #:make-generator
   #:define-generator
   #:stateful-generator
   #:hash-generator
   #:hash-generator-index
   #:rewind)
  ;; linear-congruence.lisp
  (:export
   #:linear-congruence)
  ;; mersenne-twister.lisp
  (:export
   #:mersenne-twister-32
   #:mersenne-twister-64)
  ;; middle-square.lisp
  (:export
   #:middle-square)
  ;; pcg.lisp
  (:export
   #:pcg)
  ;; protocol.lisp
  (:export
   #:random-bytes
   #:random-unit
   #:random-float
   #:random-double-float
   #:random-integer)
  ;; rc4.lisp
  (:export
   #:rc4)
  ;; tt800.lisp
  (:export
   #:tt800)
  ;; toolkit.lisp
  (:export
   #:hopefully-sufficiently-random-seed))
