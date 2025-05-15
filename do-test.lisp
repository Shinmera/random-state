#|
 This file is a part of random-state
 (c) 2023 Robert P. Goldman and SIFT, LLC
 Author: Robert P. Goldman <rpgoldman@sift.net>
|#


(in-package :common-lisp-user)

(defpackage test-random-state
  (:use :common-lisp))

(in-package :test-random-state)

(handler-bind ((error #'(lambda (c)
                          (uiop:die 4 "Error setting up for build: ~a" c))))
  ;; if we are running in roswell, we already have quicklisp installed and it's likely not in a normal
  ;; location.
  (unless (find-package :ql)
    (load (merge-pathnames (make-pathname :directory '(:relative "quicklisp") :name "setup" :type "lisp")
                           (user-homedir-pathname))))

  (push (namestring (uiop:pathname-directory-pathname *load-truename*)) (symbol-value (uiop:intern* '#:*local-project-directories* :ql)))
  (uiop:symbol-call :ql 'quickload "documentation-utils"))

(handler-case
 (assert (uiop:pathname-equal (asdf:component-pathname (asdf:find-system "random-state"))
                              (uiop:pathname-directory-pathname *load-truename*)))
  (error () (uiop:die 2 "Not loading RANDOM-STATE from the expected location.")))

;;; check for clean build
(let (warnings style-warnings)
 (handler-bind
     ((style-warning #'(lambda (x)
                         (push x style-warnings)))
      (warning #'(lambda (x)
                   (unless (typep x 'style-warning)
                     (push x warnings))))
      (error #'(lambda (c) (uiop:die 3 "Failed to build with error:~%~T~a" c))))
   (ql:quickload "random-state" :silent nil :verbose t))
  (when warnings
    (format t "Failed to build cleanly: got WARNINGs:~%~{~t~a~%~}" warnings))
  (when style-warnings
    (format t "Failed to build cleanly: got STYLE-WARNINGs:~%~{~t~a~%~}" style-warnings))
  (when (or warnings style-warnings)
   (uiop:die 3 "Failed to build cleanly: got ~a"
             (cond ((and warnings style-warnings)
                    "warnings and style warnings")
                   (warnings "warnings")
                   (style-warnings "style warnings")))))


(uiop:quit 0)
