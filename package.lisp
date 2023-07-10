(in-package #:cl-user)
(defpackage #:random-state
  (:nicknames #:org.shirakumo.random-state)
  (:use #:cl)
  (:shadow #:random)
  ;; generator.lisp
  (:export
   #:*generator*
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
   #:random
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
   #:tt800
   #:kiss11
   #:adler32
   #:murmurhash3
   #:cityhash-64
   #:xorshift-32
   #:xorshift-64
   #:xorshift-128
   #:xorshift-64*
   #:xorshift-1024*
   #:xorwow
   #:xorshift-128+
   #:xoshiro-128**
   #:xoshiro-128+
   #:xoshiro-256**
   #:xoshiro-256+))
