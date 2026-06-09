/-
# Record lens examples (macro-free)
-/

import Optics
import Optics.Automation
import tests.Common

open Optics Tests.Common

structure Point3D where
  x : Nat
  y : Nat
  z : Nat
  deriving Repr

derive_lenses Point3D

def testPoint : Point3D := { x := 1, y := 2, z := 3 }

def movedPoint : Point3D :=
  zLens.set (yLens.set (xLens.set testPoint 10) 20) 30

example : movedPoint.x = 10 := rfl
example : movedPoint.y = 20 := rfl
example : movedPoint.z = 30 := rfl

example : nameLens.get (nameLens.set testPerson "Charlie") = "Charlie" := by
  simp [nameLens, Person.nameLens]

example : ageLens.get (ageLens.set testPerson 35) = 35 := by
  simp [ageLens, Person.ageLens]

example : emailLens.get (emailLens.set testPerson "charlie@example.com") = "charlie@example.com" := by
  simp [emailLens, Person.emailLens]
