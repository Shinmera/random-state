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
         (bits (truncate32 index)))
     (update32 bits * noise1)
     (update32 bits + (truncate32 seed))
     (update32 bits logxor (ash bits -8))
     (update32 bits + noise2)
     (update32 bits logxor (ash bits 8))
     (update32 bits * noise3)
     (update32 bits logxor (ash bits -8)))))
