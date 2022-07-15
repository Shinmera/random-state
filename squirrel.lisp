#|
 This file is a part of random-state
 (c) 2015 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.random-state)

(define-generator squirrel 32 (hash-generator) ()
  (:hash
   (declare (optimize speed (safety 1)))
   (let ((noise1 #x68E31DA4)
         (noise2 #xB5297A4D)
         (noise3 #x1B56C4E9)
         (bits (fit-bits 32 index)))
     (update 32 bits * noise1)
     (update 32 bits + (fit-bits 32 seed))
     (update 32 bits logxor (ash bits -8))
     (update 32 bits + noise2)
     (update 32 bits logxor (ash bits 8))
     (update 32 bits * noise3)
     (update 32 bits logxor (ash bits -8)))))
