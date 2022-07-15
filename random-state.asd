#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem random-state
  :version "0.1.0"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :license "zlib"
  :description "Portable random number generation."
  :homepage "https://Shinmera.github.io/random-state/"
  :bug-tracker "https://github.com/Shinmera/random-state/issues"
  :source-control (:git "https://github.com/Shinmera/random-state.git")
  :serial T
  :components ((:file "package")
               (:file "toolkit")
               (:file "generator")
               (:file "protocol")
               (:file "linear-congruence")
               (:file "mersenne-twister")
               (:file "middle-square")
               (:file "pcg")
               (:file "rc4")
               (:file "tt800")
               (:file "squirrel")
               (:file "implementation")
               (:file "documentation"))
  :depends-on (:documentation-utils))
