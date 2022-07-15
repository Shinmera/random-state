#|
This file is a part of random-state
(c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

;; generator.lisp
(docs:define-docs
  (function global-generator
    "Returns a global instance of a generator.

You may also SETF this place to name specific generators of your own.

See MAKE-GENERATOR")

  (function ensure-generator
    "Ensures the argument is an object usable for random number generation.

See GLOBAL-GENERATOR
See GENERATOR")

  (function list-generator-types
    "Lists the types of generators supported by the library.

You may use any of these types to call MAKE-GENERATOR with.

See MAKE-GENERATOR")
  
  (type generator
    "General class for any random number generator.

See LIST-GENERATOR-TYPES
See SEED
See RESEED
See NEXT-BYTE
See BITS-PER-BYTE
See COPY
See MAKE-GENERATOR
See STATEFUL-GENERATOR
See HASH-GENERATOR")
  
  (function seed
    "Returns the seed that was used to initialise the generator.

See GENERATOR")
  
  (function reseed
    "Reset the RNG and seed it with the given seed number.

If T is passed for the new seed, a random seed as determined by
HOPEFULLY-SUFFICIENTLY-RANDOM-SEED is used.

See HOPEFULLY-SUFFICIENTLY-RANDOM-SEED
See GENERATOR")

  (function next-byte
    "Returns the next byte (not octet) of random state.

The returned integer must be in the range of
  [ 0, 1 << BITS-PER-BYTE GENERATOR [

See RANDOM-INT
See RANDOM-BYTES
See GENERATOR")

  (function bits-per-byte
    "Returns the number of bits of randomness returned by the generator for each NEXT-BYTE call.

See NEXT-BYTE
See GENERATOR")

  (function copy
    "Creates a fresh copy of the given generator.

This copy will return an identical sequence of bytes as the
original. Meaning, the following invariant holds true:

  (loop with copy = (copy generator) always (= (next-byte generator) (next-byte copy)))

See GENERATOR")

  (function make-generator
    "Creates a new generator of the given type.

You may pass an optional seed to initialise the generator with. If no
seed is specified, each constructed generator of the same type will
return the same sequence of numbers.

See RESEED
See GENERATOR")

  (type stateful-generator
    "Superclass for all generators that rely on state to produce random numbers.

See GENERATOR")

  (type hash-generator
    "Superclass for all generators that rely on a hashing function to generate numbers.

These generators are special in that numbers for any index can be
generated, so they can be rewound or arbitrarily stepped in their
sequence.

See GENERATOR
See INDEX
See REWIND")

  (function index
    "Accesses the index of the hash-generator.

The index must be an (unsigned-byte 64).
The index is advanced for each call to NEXT-BYTE.

See HASH-GENERATOR")

  (function rewind
    "Rewind the hash-generator by BY numbers.

The following invariant holds for any N:

  (= (next-byte generator) (progn (rewind generator N) (loop repeat (1- N) (next-byte generator)) (next-byte generator)))

See HASH-GENERATOR"))

;; protocol.lisp
(docs:define-docs
  (function random-1d
    "Returns a byte for the given index and seed.

This is only usable with HASH-GENERATOR types.
Does *NOT* advance the generator's index.

See HASH-GENERATOR
See NEXT-BYTE")

  (function random-2d
    "Returns a byte for the given location and seed.

This is only usable with HASH-GENERATOR types.
Does *NOT* advance the generator's index.

See HASH-GENERATOR
See NEXT-BYTE")

  (function random-3d
    "Returns a byte for the given location and seed.

This is only usable with HASH-GENERATOR types.
Does *NOT* advance the generator's index.

See HASH-GENERATOR
See NEXT-BYTE")

  (function random-byte
    "Alias for NEXT-BYTE.

See GENERATOR
See NEXT-BYTE")

  (function random-bytes
    "Returns an (UNSIGNED-BYTE BITS) sized random number.

May advance the generator more than once.

See GENERATOR
See NEXT-BYTE")

  (function random-sequence
    "Fills SEQUENCE between START and END with random numbers.

Note: it is up to you to ensure that SEQUENCE is capable of holding
numbers returned by the generator's NEXT-BYTE, and that doing so makes
sense. As in, do not fill a vector with element-type (unsigned-byte 8)
with a generator whose BITS-PER-BYTE is 32 or vice-versa.

Equivalent to:

  (map-into sequence (lambda () (next-byte generator)))

See GENERATOR
See NEXT-BYTE")

  (function random-unit
    "Returns a random float in [0, 1].

The returned float is of the type specified in TYPE.

see GENERATOR
See RANDOM-BYTES")

  (function random-float
    "Returns a random float in [FROM, TO].

The returned float is of the same type as whatever type is larger
between FROM and TO.

See GENERATOR
See RANDOM-UNIT")

  (function random-int
    "Returns a random integer in [FROM, TO].

See GENERATOR
See RANDOM-BYTES"))

;; toolkit.lisp
(docs:define-docs
  (function hopefully-sufficiently-random-seed
    "Attempts to find a sufficiently random seed.

On Unix, this reads 64 bits from /dev/urandom
On Windows+SBCL, this reads 64 bits from SB-WIN32:CRYPT-GEN-RANDOM
Otherwise it uses an XOR of GET-INTERNAL-REAL-TIME and GET-UNIVERSAL-TIME."))

;; * RNGs
(docs:define-docs
  (type linear-congruence
    "A very simple random number generator based on linear congruence.

See https://en.wikipedia.org/wiki/Linear_congruential_generator")
  
  (type mersenne-twister-32
    "The de-facto standard random number generator algorithm.

See https://en.wikipedia.org/wiki/Mersenne_Twister
See http://www.acclab.helsinki.fi/~knordlun/mc/mt19937.c")

  (type mersenne-twister-64
    "A 64 bit variant of the Mersenne Twister algorithm.

See MERSENNE-TWISTER-32
See http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/VERSIONS/C-LANG/mt19937-64.c")

  (type middle-square
    "An incredibly primitive, and basically in practise useless, random number algorithm.

See https://en.wikipedia.org/wiki/Middle-square_method")

  (type pcg
    "An adaptation of the PCG rng.

See http://www.pcg-random.org")

  (type rc4
    "The RC4 cryptographic random number generator.

See https://en.wikipedia.org/wiki/RC4")

  (type squirrel
    "An adaptation of the \"squirrel hash v3\".

See https://www.youtube.com/watch?v=LWFzPP8ZbdU")

  (type tt800
    "The predecessor to the Mersenne Twister algorithm.

See http://random.mat.sbg.ac.at/publics/ftp/pub/data/tt800.c"))
