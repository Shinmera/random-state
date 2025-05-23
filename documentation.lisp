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
See MULTIVARIATE-P
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

The value returned is in accordance to the spec of BITS-PER-BYTE.
If the spec is an integer, the returned integer must be in the range
of

  [ 0, 1 << BITS-PER-BYTE GENERATOR [

If the spec is SINGLE-FLOAT or DOUBLE-FLOAT, the returned float must
be in the range of

  [ 0, 1 [

If the spec is a list, the returned value is an array with each of its
elements according to the above description.

See RANDOM-INT
See RANDOM-BYTES
See GENERATOR")

  (function bits-per-byte
    "Returns the number of bits of randomness returned by the generator for each NEXT-BYTE call.

This may either be an integer, describing the bits of randomness returned,
the symbol SINGLE-FLOAT or DOUBLE-FLOAT in which case NEXT-BYTE returns a unit float,
or a list composed of the aforementioned, in which case NEXT-BYTE returns an array
of such bytes.

See NEXT-BYTE
See GENERATOR")

  (function multivariate-p
    "Returns true if the generator is multivariate and returns an array of bytes on NEXT-BYTE.

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
  
  (function define-generator
    "Define a new random number generator type.

BITS-PER-BYTE is a form that should evaluate to the byte spec for the
generator.

SUPER should be a list of the following structure:

  SUPER     ::= (type SLOT*)
  SLOT      ::= (slot-name initform)
  type      --- The structure-type name to use as supertype
  slot-name --- The name of a slot in the supertype
  initform  --- The initial value for the slot

SLOTS should be a list of additional structure slot specs to hold the
generator's state.

BODIES should be any number of body expressions, each of which is a
list composed of a body type and any number of body forms, each of
which are evaluated in an environment where every specified slot in
SLOTS as well as every specified supertype slot in SUPER is
symbol-macrolet-bound to their respective name. The following body
types are permitted:

  :COPY   --- Provides the body forms for the COPY function. The
              generator instance is bound to GENERATOR. If this body
              expression is not provided, a copy function based on the
              SLOTS is automatically provided for you.
              This must be provided for HASH-GENERATORs.
  :RESEED --- Provides the body forms for the RESEED function. The
              generator instance is bound to GENERATOR and the seed to
              SEED.
              This must be provided for STATEFUL-GENERATORs.
  :NEXT   --- Provides the body forms for the NEXT-BYTE function. The
              generator instance is bound to GENERATOR. Must return a
              suitable byte for the generator.
              This must be provided for STATEFUL-GENERATORs.
  :HASH   --- Provides the stateless hashing function. The generator
              instance is notably NOT bound. However, the 64-bit index
              to hash is bound to INDEX. This will also automatically
              provide the NEXT-BYTE function for you.
              This must be provided for HASH-GENERATORs.

Each of the additional bindings in the body expressions is bound to a
symbol from the current package.

See BITS-PER-BYTE
See RESEED
See NEXT-BYTE
See HASH
See COPY
See HASH-GENERATOR
See STATEFUL-GENERATOR
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
  (variable *generator*
    "The default random number generator used by RANDOM.

See RANDOM")

  (function draw
    "Returns a vector with N random samples in [0,1[.

See ENSURE-GENERATOR
See RANDOM-UNIT")

  (function random
    "Returns a number in [0, MAX[.

This is a drop-in replacement for CL:RANDOM.
The returned type is the same as MAX, where MAX must be an INTEGER or
a FLOAT greater than zero. The returned number must be smaller than MAX.

GENERATOR may be anything accepted by ENSURE-GENERATOR.

See RANDOM-INT
See RANDOM-FLOAT
See ENSURE-GENERATOR")
  
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
    "Returns a random float in [0, 1[.

The returned float is of the type specified in TYPE.

see GENERATOR
See RANDOM-BYTES")

  (function random-float
    "Returns a random float in [FROM, TO[.

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
Otherwise it uses an XOR of GET-INTERNAL-REAL-TIME and GET-UNIVERSAL-TIME.")

  (function histogram
    "Compute a histogram from the given sample vector.

This will collect the samples into N bins, where the value of the bin
is the contribution of the samples in the bin towards all samples.

See PRINT-HISTOGRAM
See DRAW")

  (function print-histogram
    "Display the histogram vector in a user-friendly manner.

Prints a visual representation of the deviation of each bin from the
ideal uniform distribution as well as the cumulative deviation of all
bins.

See HISTOGRAM")

  (function benchmark
    "Draw a number of samples from an NRG and determine how quickly it operates.

Prints the duration, # samples, samples/s, and s/sample to STREAM.
Returns samples/s.

See BENCHMARK-ALL")

  (function benchmark-all
    "Run a benchmark for all known generator types.

When completed, orders the the results from fastest to slowest and
prints them to STREAM. If a generator fails to be benchmarked, its
result is shown as -1.

See BENCHMARK"))

;; * RNGs
(docs:define-docs
  (type adler32
    "An RNG based on the Adler32 hash.

See https://en.wikipedia.org/wiki/Adler-32")

  (type cityhash-64
    "An RNG based on the 64-bit CityHash.

See https://github.com/google/cityhash")

  (type hammersley
    "The Hammersley quasi-random number sequence.

This is a multivariate generator with default dimensionality of 3.
To change the dimensionality, pass a :LEAP initarg that is an array of
the desired dimensionality. Each element in the LEAP array should be
an integer greater or equal to 1, and can be used to advance the
sequence more quickly for each dimension.

See https://en.wikipedia.org/wiki/Low-discrepancy_sequence")

  (type kiss11
    "An implementation of the Kiss11 RNG.

See https://eprint.iacr.org/2011/007.pdf")
  
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

  (type murmurhash3
    "A hash-based RNG using the Murmurhash3 method.

See https://en.wikipedia.org/wiki/MurmurHash")

  (type pcg
    "An adaptation of the PCG rng.

See http://www.pcg-random.org")

  (type quasi
    "A quasi-random number generator based on a uniform RNG.

When constructing the generator you may pass the :SOURCE initarg,
which should be a GENERATOR instance to use as a source of
randomness. By default the current value of *GENERATOR* is used.

See https://en.wikipedia.org/wiki/Low-discrepancy_sequence")

  (type rc4
    "The RC4 cryptographic random number generator.

See https://en.wikipedia.org/wiki/RC4")

  (type sobol
    "The Sobol quasi-random number sequence.

This is a multivariate generator with default dimensionality of 3.
You can pass the :DIM initarg to specify the dimensionality of the
result. :DIM must be in [ 1, 1111 [

See https://en.wikipedia.org/wiki/Low-discrepancy_sequence")

  (type squirrel
    "An adaptation of the \"squirrel hash v3\".

See https://www.youtube.com/watch?v=LWFzPP8ZbdU")

  (type tt800
    "The predecessor to the Mersenne Twister algorithm.

See http://random.mat.sbg.ac.at/publics/ftp/pub/data/tt800.c")

  (type xkcd
    "XKCD-221 random number generator

See https://xkcd.com/221/")

  (type xorshift-32
    "Linear 32-bit word state shift-register generator.

See https://en.wikipedia.org/wiki/Xorshift
See https://www.jstatsoft.org/article/view/v008i14")

  (type xorshift-64
    "The 64-bit variant of the Xorshift algorithm..

See XORSHIFT-32")

  (type xorshift-128
    "The four times 32-bit word state variant of the Xorshift algorithm.

See XORSHIFT-32")

  (type xorwow
    "Non-linear five times 32-bit word state shift-register generator.

See XORSHIFT-128
See https://en.wikipedia.org/wiki/Xorshift#xorwow")

  (type xorshift-64*
    "Non-linear variation of XORSHIFT-64 by adding a modulo multiplier.

See XORSHIFT-64
See https://en.wikipedia.org/wiki/Xorshift#xorshift*")

  (type xorshift-1024*
    "Sixteen 64-bit word state variation of XORSHIFT-64*.

See XORSHIFT-64*")

  (type xorshift-128+
    "Non-linear double 64-bit state variant of XORSHIFT-64 that's currently the standard on modern browsers' JavaScript engines.

See XORSHIFT-64
See https://en.wikipedia.org/wiki/Xorshift#xorshift+
See https://v8.dev/blog/math-random")

  (type xoshiro-128**
    "32-bit variant of XOSHIRO-256**.

See XOSHIRO-256**
See https://prng.di.unimi.it/xoshiro128starstar.c")

  (type xoshiro-128++
    "32-bit variant of XOSHIRO-256++.

See XOSHIRO-256++
See https://prng.di.unimi.it/xoshiro128plus.c")

  (type xoshiro-128+
    "32-bit variant of XOSHIRO-256+.

See XOSHIRO-256+
See https://prng.di.unimi.it/xoshiro128plus.c")

  (type xoshiro-256**
    "Non-linear rotating general-purpose 64-bit number algorithm.

See https://prng.di.unimi.it/
See https://prng.di.unimi.it/xoshiro256starstar.c
See https://en.wikipedia.org/wiki/Xorshift#xoshiro")

  (type xoshiro-256++
    "A variant of XOSHIRO-256** using addition instead of multiplication.

See XOSHIRO-256**
See https://prng.di.unimi.it/xoshiro256plusplus.c")

  (type xoshiro-256+
    "Slightly faster variant of XOSHIRO-256++ meant solely for generating 64-bit floating-point numbers by extracting the upper 53-bits due to the linearity of the lower bits.

See XOSHIRO-256++
See https://prng.di.unimi.it/xoshiro256plus.c")

  (type xoroshiro-64*
    "Slightly faster variant of XOROSHIRO-64** meant solely for generating 32-bit floating-point numbers by extracting the upper 26-bits due to the linearity of the lower bits.

See XOROSHIRO-64**
See https://prng.di.unimi.it/xoroshiro64star.c")

  (type xoroshiro-64**
    "32-bit variant of XOROSHIRO-128**.

See XOROSHIRO-128**
See https://prng.di.unimi.it/xoroshiro64starstar.c")

  (type xoroshiro-128+
    "A variant of XOROSHIRO-128++ that is slightly faster. It is suggested to be used for generating 64-bit floating-point values using its upper 53 bits and random boolean values using a sign test.

See XOROSHIRO-128++
See https://prng.di.unimi.it/xoroshiro128plus.c")

  (type xoroshiro-128++
    "A variant of XOROSHIRO-128** using addition instead of multiplication.

See XOROSHIRO-128**
See https://prng.di.unimi.it/xoroshiro128plusplus.c")

  (type xoroshiro-128**
    "Non-linear rotating general-purpose 64-bit number algorithm that is similar to Xoshiro-256** but uses less space.

See XOSHIRO-256**
See https://prng.di.unimi.it/
See https://prng.di.unimi.it/xoroshiro128starstar.c
See https://en.wikipedia.org/wiki/Xoroshiro128%2B"))
