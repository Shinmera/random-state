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

(defun random-byte (generator)
  (next-byte generator))

(declaim (ftype (function (T (integer 0)) (integer 0)) random-bytes))
(defun random-bytes (generator bits)
  (declare (optimize speed))
  (let* ((generator (ensure-generator generator))
         (chunk (bits-per-byte generator)))
    (declare (type (unsigned-byte 8) bits chunk))
    (cond ((= bits chunk)
           (next-byte generator))
          ((< bits chunk)
           (fit-bits bits (next-byte generator)))
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

(defun random-sequence (generator sequence &key (start 0) (end (length sequence)))
  (let ((generator (ensure-generator generator)))
    (etypecase sequence
      (list
       (loop for cons on sequence
             do (setf (car cons) (next-byte generator))))
      (vector
       (loop for i from start below end
             do (setf (aref sequence i) (next-byte generator))))
      (sequence
       (loop for i from start below end
             do (setf (elt sequence i) (next-byte generator)))))))

(defun random-unit (generator &optional (type 'single-float))
  (let* ((bits (float-digits (coerce 0 type)))
         (random (random-bytes generator bits)))
    ;; KLUDGE: this sucks. Would be better if we could directly fill the mantissa.
    (scale-float (coerce random type) (- bits))))

(define-compiler-macro random-unit (&whole whole generator &optional (type ''single-float) &environment env)
  (if (constantp type env)
      `(scale-float (coerce (random-bytes ,generator (load-time-value (float-digits (coerce 0 ,type)))) ,type)
                    (load-time-value (- (float-digits (coerce 0 ,type)))))
      whole))

(defun random-float (generator from to)
  (let ((from from)
        (to to))
    (when (< to from)
      (rotatef from to))
    (+ from (* (- to from) (random-unit generator (type-of from))))))

(define-compiler-macro random-float (&whole whole generator from to &environment env)
  (cond ((and (constantp from env) (constantp to env))
         `(+ (load-time-value (min ,to ,from))
             (* (load-time-value (abs (- ,to ,from)))
                (scale-float (float (random-bytes ,generator (load-time-value (float-digits (- ,to ,from)))) ,from)
                             (load-time-value (- (float-digits (- ,to ,from))))))))
        ((constantp from env)
         `(let ((from ,from)
                (to ,to))
            (when (< to from)
              (rotatef from to))
            (+ from
               (* (- to from)
                  (scale-float (float (random-bytes ,generator (load-time-value (float-digits ,from))) ,from)
                               (load-time-value (- (float-digits ,from))))))))
        ((constantp to env)
         `(let ((from ,from)
                (to ,to))
            (when (< to from)
              (rotatef from to))
            (+ from
               (* (- to from)
                  (scale-float (float (random-bytes ,generator (load-time-value (float-digits ,to))) ,to)
                               (load-time-value (- (float-digits ,to))))))))
        (T
         whole)))

(defun random-int (generator from to)
  (declare (optimize speed))
  (declare (type integer from to))
  (when (< to from)
    (rotatef from to))
  (let* ((generator (ensure-generator generator))
         (range (- to from))
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
