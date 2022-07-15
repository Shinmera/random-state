#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(defvar *generators* (make-hash-table :test 'eql))

(defun global-generator (name)
  (or (gethash name *generators*)
      (setf (gethash name *generators*)
            (make-generator name))))

(define-compiler-macro global-generator (&whole whole name &environment env)
  (if (constantp name env)
      `(load-time-value (or (gethash ,name *generators*)
                            (setf (gethash ,name *generators*)
                                  (make-generator ,name))))
      whole))

(defstruct (generator
            (:constructor NIL)
            (:copier NIL)
            (:conc-name NIL))
  (seed 0 :type (unsigned-byte 64)))

(defmethod print-object ((generator generator) stream)
  (print-unreadable-object (generator stream :type T)
    (format stream "~s" (seed generator))))

(defgeneric %make-generator (type &key))
(defgeneric reseed (generator new-seed))
(defgeneric next-byte (generator))
(defgeneric bits-per-byte (generator))

(defun make-generator (type &optional seed &rest initargs)
  (let ((generator (apply #'%make-generator type initargs)))
    (when seed (reseed generator seed))
    generator))

(defmethod next-byte ((generator symbol))
  (next-byte (global-generator generator)))

(defmethod reseed ((generator symbol) new-seed)
  (reseed (global-generator generator) new-seed))

(defmethod reseed ((generator generator) (new-seed (eql T)))
  (reseed generator (hopefully-sufficiently-random-seed))
  generator)

(defmacro define-generator (name bits-per-byte super slots &body bodies)
  (let ((constructor (intern* 'make name))
        (reseed (intern* name 'reseed))
        (next (intern* name 'next))
        (hash (intern* name 'hash))
        (bindings (append (loop for (slot) in slots collect
                                `(,slot (,(intern* name slot) generator)))
                          (loop for (slot) in (rest super) collect
                                `(,slot (,(intern* (first super) slot) generator)))))
        (generator (intern* 'generator))
        (seed (intern* 'seed))
        (index (intern* 'index)))
    `(progn
       (defstruct (,name
                   (:include ,@super)
                   (:constructor ,constructor)
                   (:predicate NIL))
         ,@slots)

       ,@(loop for (type . body) in bodies
               collect (ecase type
                         (:reseed
                          `(progn (defun ,reseed (,generator ,seed)
                                    (setf (seed ,generator) ,seed)
                                    (symbol-macrolet ,bindings
                                      ,@body))
                                  (defmethod reseed ((,generator ,name) (new-seed integer))
                                    (,reseed ,generator new-seed))))
                         (:next
                          `(progn (defun ,next (,generator)
                                    (symbol-macrolet ,bindings
                                      ,@body))
                                  (defmethod next-byte ((,generator ,name))
                                    (,next ,generator))))
                         (:hash
                          `(progn (defun ,hash (,index ,seed)
                                    (declare (type (unsigned-byte 64) ,index ,seed))
                                    ,@body)
                                  (defmethod hash ((,generator ,name) ,index ,seed)
                                    (,hash ,index ,seed))
                                  (defun ,next (,generator)
                                    (let ((index (truncate64 (1+ (hash-generator-index ,generator)))))
                                      (setf (hash-generator-index ,generator) index)
                                      (,hash index (seed ,generator))))
                                  (defmethod next-byte ((,generator ,name))
                                    (,next ,generator))))))

       (defmethod %make-generator ((type (eql ',name)) &rest initargs)
         (apply #',constructor initargs))
       (defmethod bits-per-byte ((generator ,name))
         ,bits-per-byte))))

(defstruct (stateful-generator
            (:include generator)
            (:constructor NIL)
            (:copier NIL)
            (:predicate NIL)))

(defstruct (hash-generator
            (:include generator)
            (:constructor NIL)
            (:copier NIL)
            (:predicate NIL))
  (index 0 :type (unsigned-byte 64)))

(defgeneric rewind (hash-generator &optional by))
(defgeneric hash (hash-generator index seed))

(defmethod make-load-form ((generator hash-generator) &optional env)
  (declare (ignore env))
  `(make-generator ',(type-of generator) ,(seed generator) :index ,(hash-generator-index generator)))

(defmethod reseed ((generator hash-generator) (seed integer))
  (setf (hash-generator-index generator) 0)
  (setf (seed generator) (truncate64 seed)))

(defmethod hash ((generator symbol) index seed)
  (hash (global-generator generator) index seed))

(defmethod rewind ((generator symbol) &optional (by 1))
  (rewind (global-generator generator) by))

(defmethod rewind ((generator hash-generator) &optional (by 1))
  (setf (index generator) (truncate64 (- (index generator) by))))
