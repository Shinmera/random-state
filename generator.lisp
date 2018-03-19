#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(defvar *generators* (make-hash-table :test 'eql))

(defun global-generator (name)
  (let ((class (generator-class name)))
    (or (gethash (class-name class) *generators*)
        (setf (gethash (class-name class) *generators*)
              (make-generator class)))))

(declaim (ftype (function (generator) (values (unsigned-byte 8))) bytes))
(defclass generator ()
  ((seed :initarg :seed :reader seed :writer set-seed)
   (bytes :initform (error "Missing BYTES initform from generator definition.") :reader bytes))
  (:default-initargs
   :seed (error "SEED required.")))

(defmethod print-object ((generator generator) stream)
  (print-unreadable-object (generator stream :type T)
    (format stream "~s" (seed generator))))

(defun generator-class (name)
  (let ((class (if (typep name 'class)
                   name
                   (let ((symbol (find-symbol (string name) '#:org.shirakumo.random-state)))
                     (or (and symbol (find-class symbol NIL))
                         (error "No such generator ~s." name))))))
    (if (subtypep (class-name class) 'generator)
        class
        (error "~a is not a subclass of generator." class))))

(defun make-generator (generator &optional seed &rest initargs)
  (let ((generator (apply #'make-instance (generator-class generator) :seed seed initargs)))
    (reseed generator seed)))

(defmacro define-generator-generic (name (generator &rest args) &rest options)
  `(progn
     (defgeneric ,name (,generator ,@args)
       ,@options)

     (defmethod ,name (,generator ,@args)
       (,name (global-generator ,generator)
              ,@(remove-if (lambda (a) (find a lambda-list-keywords)) args)))))

(declaim (ftype (function (generator) (values (integer 0))) random-byte))
(define-generator-generic random-byte (generator))

(declaim (ftype (function (generator integer) (values (integer 0))) random-bytes))
(define-generator-generic random-bytes (generator bytes))

(defmethod random-bytes ((generator generator) (bytes integer))
  (declare (optimize speed))
  (let ((chunk (bytes generator)))
    (cond ((= bytes chunk)
           (random-byte generator))
          ((< bytes chunk)
           (truncate-bits (random-byte generator) bytes))
          (T
           (let ((random 0))
             ;; Fill upper bits
             (loop for i downfrom (- bytes chunk) above 0 by chunk
                   for byte = (random-byte generator)
                   do (setf (ldb (byte chunk i) random) byte))
             ;; Fill lowermost bits.
             ;; This will cause spilling on misaligned boundaries, but we don't care.
             (setf (ldb (byte chunk 0) random) (random-byte generator))
             random)))))

(declaim (ftype (function (generator) (values double-float)) random-byte))
(define-generator-generic random-unit (generator))

(defmethod random-unit ((generator generator))
  (declare (optimize speed))
  (let* ((bits #.(integer-length most-positive-fixnum))
         (random (random-bytes generator bits)))
    (/ (float (the (integer 0) random) 0.0d0) most-positive-fixnum)))

(declaim (ftype (function (generator real real) (values double-float)) random-float))
(define-generator-generic random-float (generator from to))

(defmethod random-float :around ((generator generator) (from real) (to real))
  (declare (optimize speed))
  (if (< from to)
      (call-next-method)
      (call-next-method generator to from)))

(defmethod random-float ((generator generator) (from real) (to real))
  (declare (optimize speed))
  (+ from (* (- to from) (random-unit generator))))

(declaim (ftype (function (generator integer integer) (values integer)) random-int))
(define-generator-generic random-int (generator from to))

(defmethod random-int :around ((generator generator) (from integer) (to integer))
  (declare (optimize speed))
  (if (< from to)
      (call-next-method)
      (call-next-method generator to from)))

(defmethod random-int ((generator generator) (from integer) (to integer))
  (declare (optimize speed))
  (cond ((and (typep from 'fixnum) (typep to 'fixnum))
         (let* ((range (- to from))
                (bits (integer-length range))
                (random (random-bytes generator bits)))
           (declare (type (integer 0) random range))
           (+ from
              (if (= 0 (logand range (1+ range)))
                  random
                  (round (* range (/ random (ash 1 bits))))))))))

(declaim (ftype (function (generator &optional T) (values generator)) reseed))
(define-generator-generic reseed (generator &optional new-seed))

(defmethod reseed :around ((generator generator) &optional new-seed)
  (let ((seed (or new-seed (hopefully-sufficiently-random-seed))))
    (set-seed seed generator)
    (call-next-method generator seed))
  generator)
