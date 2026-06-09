/-
# Basic Lens Tests
-/

import Optics
import tests.Common

open Optics Tests.Common

def nameAgeLens : LawfulLens Person (String × Nat) :=
  Lens.mkLawful
    (get := fun p => (p.name, p.age))
    (set := fun p (n, a) => { p with name := n, age := a })
    (by intro p (n, a); rfl)
    (by intro p; rfl)
    (by intro p (n, a) (n', a'); rfl)

theorem nameLens_wellFormed : Lens.WellFormed nameLens :=
  Lens.lawful_wellFormed Person.nameLens

theorem ageLens_wellFormed : Lens.WellFormed ageLens :=
  Lens.lawful_wellFormed Person.ageLens

theorem nameAgeLens_wellFormed : Lens.WellFormed nameAgeLens.toLens :=
  Lens.lawful_wellFormed nameAgeLens

#eval nameLens.get testPerson
#eval nameLens.set testPerson "Bob"
#eval nameLens.over (fun n => n.toUpper) testPerson
