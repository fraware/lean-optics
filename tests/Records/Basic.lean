import Optics

-- Define a test record structure
structure Person where
  name : String
  age : Nat
  email : String
  deriving Repr

-- Test individual lens derivation
derive_lens Person name
derive_lens Person age

-- Test bulk lens derivation
derive_lenses Person

-- Test that the generated lenses work
def testPerson : Person := { name := "Alice", age := 30, email := "alice@example.com" }

-- Test individual lens usage
#check namelens : Lens Person String
#check agelens : Lens Person Nat

-- Test bulk derived lenses
#check emaillens : Lens Person String

-- Test lens operations
def updatedPerson : Person :=
  let p1 := namelens.set testPerson "Bob"
  let p2 := agelens.set p1 25
  let p3 := emaillens.set p2 "bob@example.com"
  p3

-- Verify the lens laws hold
example : namelens.get (namelens.set testPerson "Charlie") = "Charlie" := by
  simp [namelens, Lens.get, Lens.set]

example : agelens.get (agelens.set testPerson 35) = 35 := by
  simp [agelens, Lens.get, Lens.set]

example : emaillens.get (emaillens.set testPerson "charlie@example.com") = "charlie@example.com" := by
  simp [emaillens, Lens.get, Lens.set]

-- Test with a more complex structure
structure Point3D where
  x : Nat
  y : Nat
  z : Nat
  deriving Repr

-- Test bulk derivation on multiple fields
derive_lenses Point3D

def testPoint : Point3D := { x := 1, y := 2, z := 3 }

-- Verify all lenses were created
#check xlens : Lens Point3D Nat
#check ylens : Lens Point3D Nat
#check zlens : Lens Point3D Nat

-- Test lens operations
def movedPoint : Point3D :=
  let p1 := xlens.set testPoint 10
  let p2 := ylens.set p1 20
  let p3 := zlens.set p2 30
  p3

-- Verify the operations work
example : movedPoint.x = 10 := by simp [movedPoint, xlens, Lens.set]
example : movedPoint.y = 20 := by simp [movedPoint, ylens, Lens.set]
example : movedPoint.z = 30 := by simp [movedPoint, zlens, Lens.set]
