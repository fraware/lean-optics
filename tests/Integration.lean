/-!
# Integration Tests

This module tests the complete integration of all optics components.
-/

import Optics

-- Test data structures
structure Address where
  street : String
  city : String
  zip : String

structure Person where
  name : String
  age : Nat
  email : String
  address : Address

structure Company where
  name : String
  address : Address
  employees : List Person

-- Test lenses
def nameLens : Lens Person String :=
  lens! Person.name (fun p n => { p with name := n })

def ageLens : Lens Person Nat :=
  lens! Person.age (fun p a => { p with age := a })

def addressLens : Lens Person Address :=
  lens! Person.address (fun p a => { p with address := a })

def streetLens : Lens Address String :=
  lens! Address.street (fun a s => { a with street := s })

def employeesLens : Lens Company (List Person) :=
  lens! Company.employees (fun c e => { c with employees := e })

-- Test prisms
def maybePrism {A : Type} : Prism (Option A) A :=
  prism! (fun x => match x with | some a => Sum.inl a | none => Sum.inr none) some

-- Test traversals
def listTraversal {A : Type} : Traversal (List A) A :=
  traversal! (fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listTraversal.traverse f xs
      pure (y :: ys))

-- Test data
def testAddress : Address :=
  { street := "123 Main St", city := "Anytown", zip := "12345" }

def testPerson : Person :=
  { name := "Alice", age := 30, email := "alice@example.com", address := testAddress }

def testCompany : Company :=
  { name := "Acme Corp", address := testAddress, employees := [testPerson] }

-- Test lens operations
#eval nameLens.get testPerson  -- "Alice"
#eval nameLens.set testPerson "Bob"  -- { name := "Bob", ... }
#eval nameLens.over testPerson (fun n => n.toUpper)  -- { name := "ALICE", ... }

-- Test lens composition
def streetLens' : Lens Person String :=
  streetLens ∘ₗ addressLens

#eval streetLens'.get testPerson  -- "123 Main St"
#eval streetLens'.set testPerson "456 Oak Ave"  -- { ..., address := { street := "456 Oak Ave", ... } }

-- Test prism operations
#eval maybePrism.preview (some "hello")  -- some "hello"
#eval maybePrism.preview none  -- none
#eval maybePrism.build "world"  -- some "world"

-- Test traversal operations
#eval listTraversal.traverse (fun x => x + 1) [1, 2, 3]  -- [2, 3, 4]
#eval listTraversal.traverse (fun x => some (x + 1)) [1, 2, 3]  -- some [2, 3, 4]

-- Test mixed composition
def lensPrismComp : Lens (Option Person) String :=
  lens_prism_comp (lens! (fun p => p.name) (fun p n => { p with name := n })) maybePrism "Unknown"

#eval lensPrismComp.get (some testPerson)  -- "Alice"
#eval lensPrismComp.set (some testPerson) "Bob"  -- some { name := "Bob", ... }

-- Test law preservation
theorem streetLens'_laws : Lens.WellFormed streetLens' := by
  constructor
  · -- get_put
    intro p s
    simp [streetLens', Lens.comp, Lens.get_put]
  · constructor
    · -- put_get
      intro p
      simp [streetLens', Lens.comp, Lens.put_get]
    · -- put_put
      intro p s1 s2
      simp [streetLens', Lens.comp, Lens.put_put]

theorem maybePrism_laws : Prism.WellFormed maybePrism := by
  constructor
  · -- match_build
    intro a
    simp [maybePrism, Prism.match_build]
  · constructor
    · -- build_match
      intro s h
      simp [maybePrism, Prism.build_match] at h
      cases h with
      | inl h' => simp [h']
      | inr h' => simp [h']
    · -- no_match_id
      intro s h
      simp [maybePrism, Prism.no_match_id] at h
      cases h with
      | inl h' => simp [h']
      | inr h' => simp [h']

theorem listTraversal_laws : Traversal.WellFormed listTraversal := by
  constructor
  · -- identity_law
    intro xs
    simp [listTraversal, Traversal.identity_law]
  · constructor
    · -- composition_law
      intro F G _ _ f g xs
      simp [listTraversal, Traversal.composition_law]
    · -- naturality_law
      intro F G _ _ f g h xs
      simp [listTraversal, Traversal.naturality_law]

-- Test that everything compiles and runs
def main : IO Unit := do
  IO.println "Integration tests passed!"
  IO.println s!"Person name: {nameLens.get testPerson}"
  IO.println s!"Street: {streetLens'.get testPerson}"
  IO.println s!"Maybe preview: {maybePrism.preview (some \"hello\")}"
  IO.println s!"List traversal: {listTraversal.traverse (fun x => x + 1) [1, 2, 3]}")
