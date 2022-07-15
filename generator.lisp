#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(defvar *generator-types* '(random-state))
(defvar *generators* (make-hash-table :test 'eql))

(defun global-generator (name)
  (or (gethash name *generators*)
      (setf (gethash name *generators*)
            (make-generator name))))

(defun (setf global-generator) (value name)
  (setf (gethash name *generators*) value))

(define-compiler-macro global-generator (&whole whole name &environment env)
  (if (constantp name env)
      `(load-time-value (or (gethash ,name *generators*)
                            (setf (gethash ,name *generators*)
                                  (make-generator ,name))))
      whole))

(defmacro define-generator-fun (name (gen &rest args))
  (let ((argsyms (loop for arg in args unless (find arg LAMBDA-LIST-KEYWORDS) collect arg)))
    `(progn (defgeneric ,name (,gen ,@args))

            (define-compiler-macro ,name (&whole whole ,gen ,@args &environment env)
              (if (constantp ,gen env)
                  `(,',name (ensure-generator ,,gen) ,,@argsyms)
                  whole))

            (defmethod ,name ((,gen symbol) ,@args)
              (,name (global-generator ,gen) ,@argsyms)))))

(defun list-generator-types ()
  *generator-types*)

(defstruct (generator
            (:constructor NIL)
            (:copier NIL)
            (:conc-name %))
  (seed 0 :type (unsigned-byte 64)))

(defmethod print-object ((generator generator) stream)
  (print-unreadable-object (generator stream :type T)
    (format stream "~s" (seed generator))))

(defun ensure-generator (generator-ish)
  (etypecase generator-ish
    (symbol (global-generator generator-ish))
    (random-state generator-ish)
    (generator generator-ish)))

(define-compiler-macro ensure-generator (&whole whole generator-ish &environment env)
  (if (constantp generator-ish env)
      `(load-time-value (etypecase ,generator-ish
                          (symbol (global-generator ,generator-ish))
                          (random-state ,generator-ish)
                          (generator ,generator-ish)))
      whole))

(defgeneric %make-generator (type &key))
(define-generator-fun seed (generator))
(define-generator-fun reseed (generator new-seed))
(define-generator-fun next-byte (generator))
(define-generator-fun bits-per-byte (generator))
(define-generator-fun copy (generator))

(defun make-generator (type &optional seed &rest initargs)
  (let ((generator (apply #'%make-generator type initargs)))
    (when seed (reseed generator seed))
    generator))

(defmethod reseed ((generator generator) (new-seed (eql T)))
  (reseed generator (hopefully-sufficiently-random-seed))
  generator)

(defmethod seed ((generator generator))
  (%seed generator))

(defmacro define-generator (name bits-per-byte super slots &body bodies)
  (let ((constructor (intern* 'make name))
        (copy (intern* 'copy name))
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
       (pushnew ',name *generator-types*)
       
       (defstruct (,name
                   (:include ,@super)
                   (:constructor ,constructor)
                   (:copier ,copy)
                   (:predicate NIL))
         ,@slots)

       ,@(loop for (type . body) in bodies
               collect (ecase type
                         (:reseed
                          `(progn (defun ,reseed (,generator ,seed)
                                    (setf (%seed ,generator) ,seed)
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
                                    (let ((index (fit-bits 64 (1+ (index ,generator)))))
                                      (setf (index ,generator) index)
                                      (,hash index (%seed ,generator))))
                                  (defmethod next-byte ((,generator ,name))
                                    (,next ,generator))))))
       
       (defmethod copy ((generator ,name))
         (,copy generator))
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
            (:conc-name NIL)
            (:copier NIL)
            (:predicate NIL))
  (index 0 :type (unsigned-byte 64)))

(define-generator-fun rewind (hash-generator &optional by))
(define-generator-fun hash (hash-generator index seed))

(defmethod make-load-form ((generator hash-generator) &optional env)
  (declare (ignore env))
  `(make-generator ',(type-of generator) ,(seed generator) :index ,(index generator)))

(defmethod reseed ((generator hash-generator) (seed integer))
  (setf (index generator) 0)
  (setf (%seed generator) (fit-bits 64 seed)))

(defmethod rewind ((generator hash-generator) &optional (by 1))
  (setf (index generator) (fit-bits 64 (- (index generator) by))))
