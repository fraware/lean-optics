/-!
# Basic Lens Tests

This module tests basic lens functionality and laws.
-/

import Optics

-- Test record
structure Person where
  name : String
  age : Nat
  email : String

-- Test lens creation
def nameLens : Lens Person String :=
  lens! Person.name (fun p n => { p with name := n })

def ageLens : Lens Person Nat :=
  lens! Person.age (fun p a => { p with age := a })

-- Test lens laws
theorem nameLens_get_put : Lens.get_put nameLens := by
  intro p n
  simp [nameLens, Lens.get_put]

theorem nameLens_put_get : Lens.put_get nameLens := by
  intro p
  simp [nameLens, Lens.put_get]

theorem nameLens_put_put : Lens.put_put nameLens := by
  intro p n1 n2
  simp [nameLens, Lens.put_put]

-- Test lens composition
def nameAgeLens : Lens Person (String × Nat) :=
  lens! (fun p => (p.name, p.age)) (fun p (n, a) => { p with name := n, age := a })

theorem nameAgeLens_laws : Lens.WellFormed nameAgeLens := by
  constructor
  · -- get_put
    intro p (n, a)
    simp [nameAgeLens, Lens.get_put]
  · constructor
    · -- put_get
      intro p
      simp [nameAgeLens, Lens.put_get]
    · -- put_put
      intro p (n1, a1) (n2, a2)
      simp [nameAgeLens, Lens.put_put]

-- Test lens operations
def testPerson : Person :=
  { name := "Alice", age := 30, email := "alice@example.com" }

#eval nameLens.get testPerson  -- "Alice"
#eval nameLens.set testPerson "Bob"  -- { name := "Bob", age := 30, email := "alice@example.com" }
#eval nameLens.over testPerson (fun n => n.toUpper)  -- { name := "ALICE", age := 30, email := "alice@example.com" }
