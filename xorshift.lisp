(in-package #:org.shirakumo.random-state)

;; Adapted from https://en.wikipedia.org/wiki/Xorshift and Marsaglia, "Xorshift RNGs"
;;   https://www.jstatsoft.org/article/view/v008i14
;; Xoshiro adapted from https://prng.di.unimi.it/ by Sebastiano Vigna

;; Linear variations

(declaim (ftype (function (integer) (unsigned-byte 64)) splitmix64))
(defun splitmix64 (seed) ;; Ensures there are no zero seed values
  (declare (type integer seed))
  (let ((result (fit-bits 64 seed)))
    (declare (type (unsigned-byte 64) result))
    (update 64 result + #x9E3779B97f4A7C15)
    (update 64 result logxor (ash result -30))
    (update 64 result * #xBF58476D1CE4E5B9)
    (update 64 result logxor (ash result -27))
    (update 64 result * #x94D049BB133111EB)
    (update 64 result logxor (ash result -31))
    result))

(declaim (ftype (function ((unsigned-byte 8) integer) (simple-array (unsigned-byte 64) (*)))
                splitmix64-array))
(defun splitmix64-array (count seed)
  (declare (type (unsigned-byte 8) count))
  (declare (type integer seed))
  (let ((seeds (64bit-seed-array count seed)))
    (declare (type (simple-array (unsigned-byte 64) (*)) seeds))
    (loop for i from 0 below (array-dimension seeds 0)
          do (setf (aref seeds i) (splitmix64 (aref seeds i)))
          finally (return seeds))))

(declaim (ftype (function ((unsigned-byte 8) integer)
                          (simple-array (unsigned-byte 32) (*)))
                splitmix32-array))
(defun splitmix32-array (count seed)
  (declare (type (unsigned-byte 8) count))
  (declare (type integer seed))
  (let ((seeds (64bit-seed-array (ceiling count 2) seed)))
    (declare (type (simple-array (unsigned-byte 64) (*)) seeds))
    (loop with result = (make-array count :element-type '(unsigned-byte 32))
          for i from 0 below (array-dimension seeds 0)
          for j from 0 below count by 2
          for seed = (splitmix64 (aref seeds i))
          do (setf (aref result j) (fit-bits 32 seed))
          when (< (1+ j) count)
          do (setf (aref result (1+ j)) (fit-bits 32 (ash seed -32)))
          finally (return result))))

(defstruct (xorshift-generator
            (:include stateful-generator)
            (:constructor NIL)
            (:predicate NIL))
  (xorshifts (make-array 3 :element-type '(signed-byte 16))
   :type (simple-array (signed-byte 16) (3))))

(declaim (inline xorshifts))
(declaim (ftype (function (&rest (signed-byte 16)) (simple-array (signed-byte 16) (3))) xorshifts))
(defun xorshifts (&rest shifts)
  (declare (type list shifts))
  (make-array 3 :element-type '(signed-byte 16) :initial-contents shifts))

(defmacro %xorshift (bits place &optional value)
  (let ((shifts-var (gensym "XORSHIFT-SHIFTS"))
        (count-a-var (gensym "XORSHIFT-COUNT-A"))
        (count-b-var (gensym "XORSHIFT-COUNT-B"))
        (count-c-var (gensym "XORSHIFT-COUNT-C")))
    `(let* ((,shifts-var (xorshift-generator-xorshifts generator))
            (,count-a-var (aref ,shifts-var 0))
            (,count-b-var (aref ,shifts-var 1))
            (,count-c-var (aref ,shifts-var 2)))
       (xorshift-generator-xorshifts generator)
       (update ,bits ,place logxor (fit-bits ,bits (ash ,place ,count-a-var)))
       (update ,bits ,place logxor (fit-bits ,bits (ash ,place ,count-b-var)))
       ,(if value
            `(update ,bits ,place logxor value (fit-bits ,bits (ash ,value ,count-c-var)))
            `(update ,bits ,place logxor (fit-bits ,bits (ash ,place ,count-c-var)))))))

(define-generator xorshift-32 32 (xorshift-generator (xorshifts (xorshifts 13 -17 5)))
    ((value 0 :type (unsigned-byte 32)))
  (:reseed (setf value (fit-bits 32 (splitmix64 seed))))
  (:next ;; Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs"
   (%xorshift 32 value)))

(define-generator xorshift-64 64 (xorshift-generator (xorshifts (xorshifts 13 -7 17)))
    ((value 0 :type (unsigned-byte 64)))
  (:reseed (setf value (splitmix64 seed)))
  (:next ;; Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs"
   (%xorshift 64 value)))

(define-generator xorshift-128 32 (xorshift-generator (xorshifts (xorshifts 11 -8 -19)))
    ((values (make-array 4 :element-type '(unsigned-byte 32))
             :type (simple-array (unsigned-byte 32) (4))))
  (:reseed
   (setf values (splitmix32-array 4 seed)))
  (:next ;; Algorithm "xor128" from p. 5 of Marsaglia, "Xorshift RNGs"
   (let ((temp (aref values 3))
         (value (aref values 0)))
     (declare (type (unsigned-byte 32) temp value))
     (setf (aref values 3) (aref values 2))
     (setf (aref values 2) (aref values 1))
     (setf (aref values 1) value)
     (setf (aref values 0) (%xorshift 32 temp value))
     (aref values 0))))

;; Non-linear variations

(define-generator xorwow 32 (xorshift-generator (xorshifts (xorshifts -2 1 4)))
    ((counter 0 :type (unsigned-byte 32))
     (values (make-array 5 :element-type '(unsigned-byte 32))
             :type (simple-array (unsigned-byte 32) (5))))
  (:reseed
   (setf values (splitmix32-array 5 seed))
   (setf (aref values 4) 0))
  (:next ;; Algorithm "xor128" from p. 5 of Marsaglia, "Xorshift RNGs"
   (let ((temp (aref values 4))
         (value (aref values 0)))
     (declare (type (unsigned-byte 32) temp value))
     (setf (aref values 4) (aref values 3)) ;; 32 bit shift
     (setf (aref values 3) (aref values 2))
     (setf (aref values 2) (aref values 1))
     (setf (aref values 1) value)
     (setf (aref values 0) (%xorshift 32 temp value))
     (update 32 counter + 362437)
     (fit-bits 32 (+ temp counter)))))

(define-generator xorshift-64* 64 (xorshift-generator (xorshifts (xorshifts -12 25 -27)))
    ((value 0 :type (unsigned-byte 64))
     (magic #x2545f4914f6cdd1d :type (unsigned-byte 64)))
  (:reseed (setf value (splitmix64 seed)))
  (:next
   ;; variant A_1(12,25,27) with multiplier M_32 from line 3 of table 5 of Marsaglia, "Xorshift RNGs"
   (%xorshift 64 value)
   (fit-bits 64 (* value magic))))

(define-generator xorshift-1024* 64 (xorshift-generator (xorshifts (xorshifts 31 -11 30)))
    ((index 0 :type (unsigned-byte 4))
     (magic 1181783497276652981 :type (unsigned-byte 64))
     (values (make-array 16 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (16))))
  (:reseed
   (setf values (splitmix64-array 16 seed))
   (setf index 0))
  (:next ;; Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs"
   (let ((value (aref values index))
         (temp (aref values (incfmod index #x10))))
     (declare (type (unsigned-byte 64) temp value))
     (%xorshift 64 temp value)
     (setf (aref values index) temp)
     (fit-bits 64 (* temp magic)))))

(define-generator xorshift-128+ 64 (xorshift-generator (xorshifts (xorshifts 23 -18 -5)))
    ((values (make-array 2 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (2))))
  (:reseed (setf values (splitmix64-array 2 seed)))
  (:next ;; Algorithm "xor128" from p. 5 of Marsaglia, "Xorshift RNGs"
   (let ((temp (aref values 0))
         (value (aref values 1)))
     (declare (type (unsigned-byte 64) temp value))
     (setf (aref values 0) value)
     (setf (aref values 1) (%xorshift 64 temp value))
     (fit-bits 64 (+ temp value)))))

(defstruct (xoshiro-generator
            (:include stateful-generator)
            (:constructor NIL)
            (:predicate NIL)))

(declaim (inline xoshiro-rol32))
(declaim (ftype (function ((unsigned-byte 32) (signed-byte 32)) (unsigned-byte 32))
                xoshiro-rol32))
(defun xoshiro-rol32 (value count)
  (declare (type (unsigned-byte 32) value))
  (declare (type (signed-byte 32) count))
  (logior (fit-bits 32 (ash value count)) (ash value (- count 32))))

(declaim (inline xoshiro-rol64))
(declaim (ftype (function ((unsigned-byte 64) (signed-byte 32)) (unsigned-byte 64))
                xoshiro-rol64))
(defun xoshiro-rol64 (value count)
  (declare (type (unsigned-byte 64) value))
  (declare (type (signed-byte 32) count))
  (logior (fit-bits 64 (ash value count)) (ash value (- count 64))))

(defmacro %inner-xoshiro (bits value values)
  (let ((values-var (gensym "XOSHIRO-VALUES"))
        (result-var (gensym "XOSHIRO-RESULT"))
        (temp-var (gensym "XOSHIRO-TEMP"))
        (rol-fun (ecase bits (32 'xoshiro-rol32) (64 'xoshiro-rol64))))
    `(let* ((,values-var ,values)
            (,result-var ,value)
            (,temp-var (fit-bits ,bits (ash (aref ,values-var 1)
                                            ,(ecase bits (32 9) (64 17))))))
       (update ,bits (aref ,values-var 2) logxor (aref ,values-var 0))
       (update ,bits (aref ,values-var 3) logxor (aref ,values-var 1))
       (update ,bits (aref ,values-var 1) logxor (aref ,values-var 2))
       (update ,bits (aref ,values-var 0) logxor (aref ,values-var 3))
       (update ,bits (aref ,values-var 2) logxor ,temp-var)
       (update ,bits (aref ,values-var 3) ,rol-fun
               ,(ecase bits (32 11) (64 45)))
       ,result-var)))

(define-generator xoshiro-128** 32 (stateful-generator)
    ((values (make-array 4 :element-type '(unsigned-byte 32))
             :type (simple-array (unsigned-byte 32) (4))))
  (:reseed
   (setf values (splitmix32-array 4 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (%inner-xoshiro
    32
    (fit-bits 32 (* (xoshiro-rol32 (fit-bits 32 (* (aref values 1) 5)) 7) 9))
    values)))

(define-generator xoshiro-128++ 32 (stateful-generator)
    ((values (make-array 4 :element-type '(unsigned-byte 32))
             :type (simple-array (unsigned-byte 32) (4))))
  (:reseed
   (setf values (splitmix32-array 4 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (%inner-xoshiro
    32
    (fit-bits 32 (+ (xoshiro-rol32 (fit-bits 32 (+ (aref values 0) (aref values 3))) 7)
                    (aref values 0)))
    values)))

(define-generator xoshiro-128+ 32 (stateful-generator)
    ((values (make-array 4 :element-type '(unsigned-byte 32))
             :type (simple-array (unsigned-byte 32) (4))))
  (:reseed
   (setf values (splitmix32-array 4 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (%inner-xoshiro 32 (fit-bits 32 (+ (aref values 0) (aref values 3))) values)))

(define-generator xoshiro-256** 64 (stateful-generator)
    ((values (make-array 4 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (4))))
  (:reseed
   (setf values (splitmix64-array 4 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (%inner-xoshiro
    64
    (fit-bits 64 (* (xoshiro-rol64 (fit-bits 64 (* (aref values 1) 5)) 7) 9))
    values)))

(define-generator xoshiro-256++ 64 (stateful-generator)
    ((values (make-array 4 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (4))))
  (:reseed
   (setf values (splitmix64-array 4 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (%inner-xoshiro
    64
    (fit-bits 64 (+ (xoshiro-rol64 (fit-bits 64 (+ (aref values 0) (aref values 3))) 23)
                    (aref values 0)))
    values)))

(define-generator xoshiro-256+ 64 (stateful-generator)
    ((values (make-array 4 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (4))))
  (:reseed
   (setf values (splitmix64-array 4 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (%inner-xoshiro 64 (fit-bits 64 (+ (aref values 0) (aref values 3))) values)))

;; Xoroshiro variants.

(define-generator xoroshiro-64* 32 (stateful-generator)
    ((magic #x9e3779bb)
     (values (make-array 2 :element-type '(unsigned-byte 32))
             :type (simple-array (unsigned-byte 32) (2))))
  (:reseed
   (setf values (splitmix32-array 2 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (let* ((temp (aref values 0))
          (value (aref values 1))
          (result (fit-bits 32 (* temp magic))))
     (update 32 temp logxor value)
     (setf (aref values 0) (logxor (xoshiro-rol32 temp 26) value (fit-bits 32 (ash value 9))))
     (setf (aref values 1) (xoshiro-rol32 value 13))
     result)))

(define-generator xoroshiro-64** 32 (stateful-generator)
    ((magic #x9e3779bb)
     (values (make-array 2 :element-type '(unsigned-byte 32))
             :type (simple-array (unsigned-byte 32) (2))))
  (:reseed
   (setf values (splitmix32-array 2 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (let* ((temp (aref values 0))
          (value (aref values 1))
          (result (fit-bits 32 (* (xoshiro-rol32 (fit-bits 32 (* temp magic)) 5) 5))))
     (update 32 temp logxor value)
     (setf (aref values 0) (logxor (xoshiro-rol32 temp 26) value (fit-bits 32 (ash value 9))))
     (setf (aref values 1) (xoshiro-rol32 value 13))
     result)))

(define-generator xoroshiro-128+ 64 (stateful-generator)
    ((values (make-array 2 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (2))))
  ;; TODO: This algorithm allows a quick generation of 2^64 :next-calls.
  ;;       See jump() and long_jump() functions in https://prng.di.unimi.it/xoroshiro128plus.c
  (:reseed
   (setf values (splitmix64-array 2 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (let* ((temp (aref values 0))
          (value (aref values 1))
          (result (fit-bits 64 (+ temp value))))
     (update 64 temp logxor value)
     (setf (aref values 0) (logxor (xoshiro-rol64 temp 24) value (fit-bits 64 (ash value 16))))
     (setf (aref values 1) (xoshiro-rol64 value 37))
     result)))

(define-generator xoroshiro-128++ 64 (stateful-generator)
    ((values (make-array 2 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (2))))
  ;; TODO: This algorithm allows a quick generation of 2^64 :next-calls.
  ;;       See jump() and long_jump() functions in https://prng.di.unimi.it/xoroshiro128plusplus.c
  (:reseed
   (setf values (splitmix64-array 2 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (let* ((temp (aref values 0))
          (value (aref values 1))
          (result (fit-bits 64 (+ (xoshiro-rol64 (fit-bits 64 (+ temp value)) 17) temp))))
     (update 64 temp logxor value)
     (setf (aref values 0) (logxor (xoshiro-rol64 temp 49) value (fit-bits 64 (ash value 21))))
     (setf (aref values 1) (xoshiro-rol64 value 28))
     result)))

(define-generator xoroshiro-128** 64 (stateful-generator)
    ((values (make-array 2 :element-type '(unsigned-byte 64))
             :type (simple-array (unsigned-byte 64) (2))))
  ;; TODO: This algorithm allows a quick generation of 2^64 :next-calls.
  ;;       See jump() and long_jump() functions in https://prng.di.unimi.it/xoroshiro128starstar.c
  (:reseed
   (setf values (splitmix64-array 2 seed)))
  (:next ;; Adapted from works by Sebastiano Vigna
   (let* ((temp (aref values 0))
          (value (aref values 1))
          (result (fit-bits 64 (* (xoshiro-rol64 (fit-bits 64 (* temp 5)) 7) 9))))
     (update 64 temp logxor value)
     (setf (aref values 0) (logxor (xoshiro-rol64 temp 24) value (fit-bits 64 (ash value 16))))
     (setf (aref values 1) (xoshiro-rol64 value 37))
     result)))
