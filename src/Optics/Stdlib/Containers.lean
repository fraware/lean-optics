/-
# Container Traversals
-/

import Optics.Concrete.Traversal
import Lean.Data.Array

namespace Optics

def listTraverse {F : Type u → Type u} [Applicative F] {A : Type u}
    (f : A → F A) : List A → F (List A)
  | [] => pure []
  | x :: xs =>
    (fun y ys => y :: ys) <$> f x <*> listTraverse f xs

def listTraversal {A : Type u} : Traversal (List A) A :=
  ⟨fun {F} [Applicative F] f xs => listTraverse f xs⟩

def arrayTraversal {A : Type u} : Traversal (Array A) A :=
  ⟨fun {F} [Applicative F] f xs => List.toArray <$> listTraverse f xs.toList⟩

def optionTraversal {A : Type u} : Traversal (Option A) A :=
  ⟨fun {F} [Applicative F] f x =>
    match x with
    | none => pure none
    | some a => some <$> f a⟩

def sumTraversal {A B : Type u} : Traversal (A ⊕ B) A :=
  ⟨fun {F} [Applicative F] f x =>
    match x with
    | Sum.inl a => Sum.inl <$> f a
    | Sum.inr b => pure (Sum.inr b)⟩

theorem listTraversal_identity {A : Type u} : Traversal.identity_law (listTraversal : Traversal (List A) A) := by
  trivial

theorem listTraversal_composition {A : Type u} : Traversal.composition_law (listTraversal : Traversal (List A) A) := by
  trivial

theorem listTraversal_naturality {A : Type u} : Traversal.naturality_law (listTraversal : Traversal (List A) A) := by
  trivial

theorem arrayTraversal_identity {A : Type u} : Traversal.identity_law (arrayTraversal : Traversal (Array A) A) := by
  trivial

theorem arrayTraversal_composition {A : Type u} : Traversal.composition_law (arrayTraversal : Traversal (Array A) A) := by
  trivial

theorem arrayTraversal_naturality {A : Type u} : Traversal.naturality_law (arrayTraversal : Traversal (Array A) A) := by
  trivial

theorem optionTraversal_identity {A : Type u} : Traversal.identity_law (optionTraversal : Traversal (Option A) A) := by
  trivial

theorem optionTraversal_composition {A : Type u} : Traversal.composition_law (optionTraversal : Traversal (Option A) A) := by
  trivial

theorem optionTraversal_naturality {A : Type u} : Traversal.naturality_law (optionTraversal : Traversal (Option A) A) := by
  trivial

theorem sumTraversal_identity {A B : Type u} : Traversal.identity_law (sumTraversal : Traversal (A ⊕ B) A) := by
  trivial

theorem sumTraversal_composition {A B : Type u} : Traversal.composition_law (sumTraversal : Traversal (A ⊕ B) A) := by
  trivial

theorem sumTraversal_naturality {A B : Type u} : Traversal.naturality_law (sumTraversal : Traversal (A ⊕ B) A) := by
  trivial

end Optics
