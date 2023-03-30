(defpackage random-state-tests
  (:shadowing-import-from #:random-state #:random)
  (:use #:random-state common-lisp #:fiveam))

(in-package random-state-tests)

(def-suite* random-state-tests)

(def-suite* repeatability :in random-state-tests)

(test import
  (fiveam:is (eq 'random 'random-state:random))
  (fiveam:is-false (eq 'random 'cl:random))
  )

(defmacro repeatable-generator (type)
  (let ((test-name (intern (format nil "~A-RANDOM-REPEATABLE" type) :random-state-tests)))
   (test ,test-name
      (let ((new-generator (random-state:make-generator ,type (hopefully-sufficiently-random-seed)))
            sequence1 sequence2)
        (let ((*random-generator* (copy new-generator)))
          (setf sequence1 (let (sequence)
                            (dotimes (x 10)
                              (push
                               (random 10)
                               sequence))
                            sequence)))
        (let ((*random-generator* (copy new-generator)))
          (setf sequence2 (let (sequence)
                            (dotimes (x 10)
                              (push
                               (random 10)
                               sequence))
                            sequence)))
        (fiveam::is (equalp sequence1 sequence2))))))

;;; don't love this code, but haven't figured out an alternative.
(eval-when (:load-toplevel :execute)
  (eval (cons 'progn
              (loop for gen in (list-generator-types)
                    collect `(repeatable-generator ,gen)))))




