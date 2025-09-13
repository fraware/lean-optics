/-!
# Container Traversals

This module provides traversals for standard containers like List, Array, and Vector.
-/

import Optics.Concrete.Traversal
import Lean.Data.Array

namespace Optics

/-- Traversal for List. -/
def listTraversal {A : Type u} : Traversal (List A) A :=
  ⟨fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listTraversal.traverse f xs
      pure (y :: ys)⟩

/-- Traversal for Array. -/
def arrayTraversal {A : Type u} : Traversal (Array A) A :=
  ⟨fun {F} [Applicative F] f xs =>
    xs.mapM f⟩

/-- Traversal for Vector. -/
def vectorTraversal {A : Type u} {n : Nat} : Traversal (Vector A n) A :=
  ⟨fun {F} [Applicative F] f xs =>
    match xs with
    | Vector.nil => pure Vector.nil
    | Vector.cons x xs => do
      let y ← f x
      let ys ← vectorTraversal.traverse f xs
      pure (Vector.cons y ys)⟩

/-- Traversal for Option. -/
def optionTraversal {A : Type u} : Traversal (Option A) A :=
  ⟨fun {F} [Applicative F] f x =>
    match x with
    | none => pure none
    | some a => some <$> f a⟩

/-- Traversal for Sum. -/
def sumTraversal {A B : Type u} : Traversal (A ⊕ B) A :=
  ⟨fun {F} [Applicative F] f x =>
    match x with
    | Sum.inl a => Sum.inl <$> f a
    | Sum.inr b => pure (Sum.inr b)⟩

/-- Traversal for Either. -/
def eitherTraversal {A B : Type u} : Traversal (Either A B) A :=
  ⟨fun {F} [Applicative F] f x =>
    match x with
    | Either.left a => Either.left <$> f a
    | Either.right b => pure (Either.right b)⟩

/-- Traversal for Result. -/
def resultTraversal {A E : Type u} : Traversal (Result E A) A :=
  ⟨fun {F} [Applicative F] f x =>
    match x with
    | Result.ok a => Result.ok <$> f a
    | Result.err e => pure (Result.err e)⟩

/-- Law proofs for container traversals -/

@[optic.law]
theorem listTraversal_identity {A : Type u} : Traversal.identity_law (listTraversal : Traversal (List A) A) := by
  intro xs
  simp [listTraversal, Traversal.identity_law]
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [ih]

@[optic.law]
theorem listTraversal_composition {A : Type u} : Traversal.composition_law (listTraversal : Traversal (List A) A) := by
  intro F G _ _ f g xs
  simp [listTraversal, Traversal.composition_law]
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [ih]

@[optic.law]
theorem listTraversal_naturality {A : Type u} : Traversal.naturality_law (listTraversal : Traversal (List A) A) := by
  intro F G _ _ f g h xs
  simp [listTraversal, Traversal.naturality_law]
  induction xs with
  | nil => rfl
  | cons x xs ih => simp [ih]

@[optic.law]
theorem arrayTraversal_identity {A : Type u} : Traversal.identity_law (arrayTraversal : Traversal (Array A) A) := by
  intro xs
  simp [arrayTraversal, Traversal.identity_law]

@[optic.law]
theorem arrayTraversal_composition {A : Type u} : Traversal.composition_law (arrayTraversal : Traversal (Array A) A) := by
  intro F G _ _ f g xs
  simp [arrayTraversal, Traversal.composition_law]

@[optic.law]
theorem arrayTraversal_naturality {A : Type u} : Traversal.naturality_law (arrayTraversal : Traversal (Array A) A) := by
  intro F G _ _ f g h xs
  simp [arrayTraversal, Traversal.naturality_law]

@[optic.law]
theorem optionTraversal_identity {A : Type u} : Traversal.identity_law (optionTraversal : Traversal (Option A) A) := by
  intro x
  simp [optionTraversal, Traversal.identity_law]
  cases x <;> rfl

@[optic.law]
theorem optionTraversal_composition {A : Type u} : Traversal.composition_law (optionTraversal : Traversal (Option A) A) := by
  intro F G _ _ f g x
  simp [optionTraversal, Traversal.composition_law]
  cases x <;> rfl

@[optic.law]
theorem optionTraversal_naturality {A : Type u} : Traversal.naturality_law (optionTraversal : Traversal (Option A) A) := by
  intro F G _ _ f g h x
  simp [optionTraversal, Traversal.naturality_law]
  cases x <;> rfl

end Optics
