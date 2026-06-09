/-
# Lawful lens example (no macros)

Upstream CSLib candidate: explicit `LawfulLens` construction over a simple record.
-/

import Optics

namespace Optics.Examples

structure Person where
  name : String
  age : Nat

def nameLens : LawfulLens Person String :=
  Lens.mkLawful
    (get := Person.name)
    (set := fun p n => { p with name := n })
    (get_set := by intro p n; rfl)
    (set_get := by intro p; rfl)
    (set_set := by intro p n1 n2; rfl)

def ageLens : LawfulLens Person Nat :=
  Lens.mkLawful
    (get := Person.age)
    (set := fun p a => { p with age := a })
    (get_set := by intro p a; rfl)
    (set_get := by intro p; rfl)
    (set_set := by intro p a1 a2; rfl)

def updateName (p : Person) : Person :=
  nameLens.over (fun n => n.toUpper) p

def alice : Person := { name := "Alice", age := 30 }

#eval nameLens.get alice
#eval updateName alice

end Optics.Examples
