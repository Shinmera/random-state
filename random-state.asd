(asdf:defsystem random-state
  :version "1.0.1"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :license "zlib"
  :description "Portable random number generation."
  :homepage "https://shinmera.com/docs/random-state/"
  :bug-tracker "https://shinmera.com/project/random-state/issues"
  :source-control (:git "https://shinmera.com/project/random-state.git")
  :in-order-to ((test-op (test-op "random-state-test")))
  :serial T
  :components ((:file "package")
               (:file "toolkit")
               (:file "generator")
               (:file "protocol")
               (:file "primes")
               (:file "adler32")
               (:file "cityhash")
               (:file "hammersley")
               (:file "linear-congruence")
               (:file "kiss")
               (:file "mersenne-twister")
               (:file "middle-square")
               (:file "murmurhash")
               (:file "pcg")
               (:file "quasi")
               (:file "rc4")
               (:file "sobol")
               (:file "squirrel")
               (:file "tt800")
               (:file "xkcd")
               (:file "xorshift")
               (:file "implementation")
               (:file "histogram")
               (:file "documentation"))
  :depends-on (:documentation-utils)
  :in-order-to ((asdf:test-op (asdf:test-op :random-state-test))))

(asdf:defsystem random-state/test
  :version "1.0.0"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :license "zlib"
  :description "Portable random number generation."
  :homepage "https://shinmera.com/docs/random-state/"
  :bug-tracker "https://shinmera.com/project/random-state/issues"
  :source-control (:git "https://shinmera.com/project/random-state.git")
  :serial T
  :components ((:file "test"))
  :depends-on (:random-state :parachute)
  :perform (asdf:test-op (op c) (uiop:symbol-call :parachute :test :org.shirakumo.random-state.test)))

(asdf:defsystem random-state/viewer
  :version "1.0.0"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
  :license "zlib"
  :description "Visualiser for the random number generators"
  :homepage "https://shinmera.com/docs/random-state/"
  :bug-tracker "https://shinmera.com/project/random-state/issues"
  :source-control (:git "https://shinmera.com/project/random-state.git")
  :serial T
  :components ((:file "viewer"))
  :depends-on (:random-state
               :zpng
               :trivial-features
               :uiop))
