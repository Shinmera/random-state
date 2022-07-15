#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(defun random-1d (generator index &optional (seed 0))
  (hash generator index seed))

(defun random-2d (generator x y &optional (seed 0))
  (hash generator (+ x (* y 198491317)) seed))

(defun random-3d (generator x y z &optional (seed 0))
  (hash generator (+ x (* y 198491317) (* z 6542989)) seed))

(defun random-bytes (generator bits)
  (declare (optimize speed))
  (let ((chunk (bits-per-byte generator)))
    (declare (type (unsigned-byte 8) bits chunk))
    (cond ((= bits chunk)
           (next-byte generator))
          ((< bits chunk)
           (truncate-bits (next-byte generator) bits))
          (T
           (let ((random 0))
             ;; Fill upper bits
             (loop for i downfrom (- bits chunk) above 0 by chunk
                   for byte = (next-byte generator)
                   do (setf (ldb (byte chunk i) random) byte))
             ;; Fill lowermost bits.
             ;; This will cause spilling on misaligned boundaries, but we don't care.
             (setf (ldb (byte chunk 0) random) (next-byte generator))
             random)))))

(defun random-unit (generator type)
  (declare (optimize speed))
  (declare (type float type))
  (let* ((bits #.(integer-length most-positive-fixnum))
         (random (random-bytes generator bits)))
    ;; KLUDGE: this sucks
    (/ (float (the (integer 0) random) type)
       most-positive-fixnum)))

(defun random-float (generator from to)
  (declare (optimize speed))
  (let ((from (float from 0f0))
        (to (float to 0f0)))
    (when (< to from)
      (rotatef from to))
    (+ from (* (- to from) (the single-float (random-unit generator 0f0))))))

(defun random-double-float (generator from to)
  (declare (optimize speed))
  (let ((from (float from 0d0))
        (to (float to 0d0)))
    (when (< to from)
      (rotatef from to))
    (+ from (* (- to from) (the double-float (random-unit generator 0d0))))))

(defmethod random-integer :around (generator from to)
  (declare (optimize speed))
  (declare (type integer from to))
  (when (< to from)
    (rotatef from to))
  (let* ((range (- to from))
         (bits (integer-length range)))
    (declare (type (unsigned-byte 64) range)
             (type (unsigned-byte 8) bits))
    (+ from
       ;; CANDIDATE is in the range [0, 2^BITS). Trying to map
       ;; this to our target range will introduce bias -- for example,
       ;; in the [0, 2] case, you could map 0->0, 1->0, 2->1, 3->2 and 0 would
       ;; come up twice as often as 1 & 2. So we instead re-roll until we get
       ;; a candidate in our range. Bigger range = fewer expected rolls.
       ;; But even in the 0..2 case, the expected number of rolls is still only ~1.33:
       ;;    E[R] = (3/4)1 + (1/4)(1 + E[R]),
       ;;    4E[R] = 3 + 1 + E[R],
       ;;    E[R] = 4/3 = ~1.33.
       (loop for candidate = (random-bytes generator bits)
             when (<= candidate range)
             return candidate))))
