/-!
# Basic Composition Tests

This module tests composition of different optic types.
-/

import Optics

-- Test record
structure Address where
  street : String
  city : String
  zip : String

structure Person where
  name : String
  age : Nat
  address : Address

-- Test lens composition
def streetLens : Lens Address String :=
  lens! Address.street (fun a s => { a with street := s })

def addressLens : Lens Person Address :=
  lens! Person.address (fun p a => { p with address := a })

def streetLens' : Lens Person String :=
  streetLens ∘ₗ addressLens

-- Test lens composition laws
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

-- Test prism composition
def maybePrism {A : Type} : Prism (Option A) A :=
  prism! (fun x => match x with | some a => Sum.inl a | none => Sum.inr none) some

def maybeStringPrism : Prism (Option String) String :=
  prism! (fun x => match x with | some s => Sum.inl s | none => Sum.inr none) some

def maybeStringPrism' : Prism (Option String) String :=
  maybeStringPrism ∘ₚ maybePrism

-- Test prism composition laws
theorem maybeStringPrism'_laws : Prism.WellFormed maybeStringPrism' := by
  constructor
  · -- match_build
    intro s
    simp [maybeStringPrism', Prism.comp, Prism.match_build]
  · constructor
    · -- build_match
      intro s h
      simp [maybeStringPrism', Prism.comp, Prism.build_match] at h
      cases h with
      | inl h' => simp [h']
      | inr h' => simp [h']
    · -- no_match_id
      intro s h
      simp [maybeStringPrism', Prism.comp, Prism.no_match_id] at h
      cases h with
      | inl h' => simp [h']
      | inr h' => simp [h']

-- Test traversal composition
def listTraversal {A : Type} : Traversal (List A) A :=
  traversal! (fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listTraversal.traverse f xs
      pure (y :: ys))

def listStringTraversal : Traversal (List String) String :=
  traversal! (fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listStringTraversal.traverse f xs
      pure (y :: ys))

def listStringTraversal' : Traversal (List String) String :=
  listStringTraversal ∘ₜ listTraversal

-- Test traversal composition laws
theorem listStringTraversal'_laws : Traversal.WellFormed listStringTraversal' := by
  constructor
  · -- identity_law
    intro xs
    simp [listStringTraversal', Traversal.comp, Traversal.identity_law]
  · constructor
    · -- composition_law
      intro F G _ _ f g xs
      simp [listStringTraversal', Traversal.comp, Traversal.composition_law]
    · -- naturality_law
      intro F G _ _ f g h xs
      simp [listStringTraversal', Traversal.comp, Traversal.naturality_law]
