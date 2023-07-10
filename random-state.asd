(asdf:defsystem random-state
  :version "1.0.1"
  :author "Yukari Hafner <shinmera@tymoon.eu>"
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
               (:file "kiss")
               (:file "squirrel")
               (:file "adler32")
               (:file "murmurhash")
               (:file "cityhash")
               (:file "xorshift")
               (:file "implementation")
               (:file "documentation"))
  :depends-on (:documentation-utils)
  :in-order-to ((asdf:test-op (asdf:test-op :random-state-test))))
