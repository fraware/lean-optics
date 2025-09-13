/-!
# Basic Traversal Tests

This module tests basic traversal functionality and laws.
-/

import Optics

-- Test traversal for List
def listTraversal {A : Type} : Traversal (List A) A :=
  traversal! (fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listTraversal.traverse f xs
      pure (y :: ys))

-- Test traversal laws
theorem listTraversal_identity : Traversal.identity_law listTraversal := by
  intro xs
  simp [listTraversal, Traversal.identity_law]

theorem listTraversal_composition : Traversal.composition_law listTraversal := by
  intro F G _ _ f g xs
  simp [listTraversal, Traversal.composition_law]

theorem listTraversal_naturality : Traversal.naturality_law listTraversal := by
  intro F G _ _ f g h xs
  simp [listTraversal, Traversal.naturality_law]

-- Test traversal operations
#eval listTraversal.traverse (fun x => x + 1) [1, 2, 3]  -- [2, 3, 4]
#eval listTraversal.traverse (fun x => some (x + 1)) [1, 2, 3]  -- some [2, 3, 4]

-- Test traversal composition
def listStringTraversal : Traversal (List String) String :=
  traversal! (fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listStringTraversal.traverse f xs
      pure (y :: ys))

theorem listStringTraversal_laws : Traversal.WellFormed listStringTraversal := by
  constructor
  · -- identity_law
    intro xs
    simp [listStringTraversal, Traversal.identity_law]
  · constructor
    · -- composition_law
      intro F G _ _ f g xs
      simp [listStringTraversal, Traversal.composition_law]
    · -- naturality_law
      intro F G _ _ f g h xs
      simp [listStringTraversal, Traversal.naturality_law]
