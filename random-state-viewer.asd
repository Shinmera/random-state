#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(asdf:defsystem random-state-viewer
  :version "1.0.0"
  :author "Nicolas Hafner <shinmera@tymoon.eu>"
  :license "zlib"
  :description "Visualiser for the random number generators"
  :homepage "https://Shinmera.github.io/random-state/"
  :bug-tracker "https://github.com/Shinmera/random-state/issues"
  :source-control (:git "https://github.com/Shinmera/random-state.git")
  :serial T
  :components ((:file "viewer"))
  :depends-on (:random-state
               :qtools
               :qtcore
               :qtgui))
