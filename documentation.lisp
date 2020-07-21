#|
This file is a part of random-state
(c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(docs:define-docs
  (function global-generator
    "Returns a global instance of a generator.

See MAKE-GENERATOR")
  
  (type generator
    "General class for any random number generator.

See SEED
See BYTES
See MAKE-GENERATOR
See RANDOM-BYTE
See RANDOM-BYTES
See RANDOM-UNIT
See RANDOM-FLOAT
See RANDOM-INT
See RESEED")
  
  (function seed
    "Returns the seed that was used to initialise the generator.")
  
  (function bytes
    "Returns the number of bytes (bits) that a RANDOM-BYTE call of this generator produces.")
  
  (function generator-class
    "Attempts to find the named generator class. Accepts strings, symbols, and classes.

If no generator can be found, an error is signalled.")
  
  (function make-generator
    "Creates a generator of the given type.

The GENERATOR can be any name supported by GENERATOR-CLASS.

SEED must be an integer.

After construction, RESEED is called on the generator with the given SEED.

Example:
  (random-state:make-generator :mersenne-twister-32 42)

See GENERATOR-CLASS
See RESEED")
  
  (function random-byte
    "Returns an integer of fresh random output from the generator.

The integer is at most 2^(BYTES GENERATOR)-1 and at least 0.

See GENERATOR
See BYTES")
  
  (function random-bytes
    "Returns an integer of fresh random output from the generator.

The integer is at most 2^(BYTES)-1 and at least 0.

See GENERATOR
See RANDOM-BYTE")
  
  (function random-unit
    "Returns a unit float of fresh random output from the generator.

The returned value is a double-float between 0.0 and 1.0.

See GENERATOR")
  
  (function random-float
    "Returns a float of fresh random output from the generator.

The returned value is a double-float between FROM and TO.

See GENERATOR")
  
  (function random-int
    "Returns an integer of fresh random output from the generator.

The returned value is an integer between FROM (inclusive) and TO (inclusive).

See GENERATOR")
  
  (function reseed
    "Reinitialises the generator with the new seed. 

The seed should be an integer. If not given, the current value returned by
HOPEFULLY-SUFFICIENTLY-RANDOM-SEED is used."))

;; linear-congruence.lisp
(docs:define-docs
  (type linear-congruence
    "A very simple random number generator based on linear congruence.

See https://en.wikipedia.org/wiki/Linear_congruential_generator"))

;; mersenne-twister.lisp
(docs:define-docs
  (type mersenne-twister-32
    "The de-facto standard random number generator algorithm.

See https://en.wikipedia.org/wiki/Mersenne_Twister
See http://www.acclab.helsinki.fi/~knordlun/mc/mt19937.c")
  
  (type mersenne-twister-64
    "A 64 bit variant of the Mersenne Twister algorithm.

See MERSENNE-TWISTER-32
See http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/VERSIONS/C-LANG/mt19937-64.c"))

;; middle-square.lisp
(docs:define-docs
  (type middle-square
    "An incredibly primitive, and basically in practise useless, random number algorithm.

See https://en.wikipedia.org/wiki/Middle-square_method"))

;; pcg.lisp
(docs:define-docs
  (type pcg
    "An adaptation of the PCG rng.

See http://www.pcg-random.org"))

;; rc4.lisp
(docs:define-docs
  (type rc4
    "The RC4 cryptographic random number generator.

See https://en.wikipedia.org/wiki/RC4"))

;; tt800.lisp
(docs:define-docs
  (type tt800
    "The predecessor to the Mersenne Twister algorithm.

See http://random.mat.sbg.ac.at/publics/ftp/pub/data/tt800.c"))

;; toolkit.lisp
(docs:define-docs
  (function hopefully-sufficiently-random-seed
    "Attempts to find a sufficiently random seed.

On Unix, this reads 64 bits from /dev/urandom
On Windows+SBCL, this reads 64 bits from SB-WIN32:CRYPT-GEN-RANDOM
Otherwise it uses an XOR of GET-INTERNAL-REAL-TIME and GET-UNIVERSAL-TIME."))
