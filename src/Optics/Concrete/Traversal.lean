/-!
# Concrete Traversal Implementation

This module implements the concrete Traversal structure with laws and isomorphisms
to profunctor optics.
-/

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav

namespace Optics

/-- A traversal focuses on multiple parts of a structure. -/
structure Traversal (S A : Type u) where
  /-- Traverse over the focused parts with an applicative functor. -/
  traverse : {F : Type u → Type u} → [Applicative F] → (A → F A) → S → F S

namespace Traversal

/-- Create a traversal from a traverse function. -/
def mk (tr : {F : Type u → Type u} → [Applicative F] → (A → F A) → S → F S) : Traversal S A :=
  ⟨tr⟩

/-- Compose two traversals. -/
def comp (t₁ : Traversal S A) (t₂ : Traversal A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    t₁.traverse (fun a => t₂.traverse f a) s⟩

/-- Traversal laws -/

/-- Identity law: traversing with identity is identity. -/
def identity_law (t : Traversal S A) : Prop :=
  ∀ s, t.traverse (fun a => pure a) s = pure s

/-- Composition law: traversing with composed applicatives is equivalent to composing traversals. -/
def composition_law (t : Traversal S A) : Prop :=
  ∀ {F G : Type u → Type u} [Applicative F] [Applicative G] (f : A → F A) (g : A → G A) s,
    t.traverse (fun a => f a <*> g a) s =
    t.traverse f s <*> t.traverse g s

/-- Naturality law: traversing respects applicative morphisms. -/
def naturality_law (t : Traversal S A) : Prop :=
  ∀ {F G : Type u → Type u} [Applicative F] [Applicative G] (f : A → F A) (g : A → G A) (h : F A → G A) s,
    h (t.traverse f s) = t.traverse (h ∘ f) s

/-- A traversal is well-formed if it satisfies all traversal laws. -/
def WellFormed (t : Traversal S A) : Prop :=
  identity_law t ∧ composition_law t ∧ naturality_law t

/-- Isomorphism between traversals and profunctor optics -/

/-- Convert a traversal to a profunctor optic. -/
def toOptic (t : Traversal S A) : Optic Traversing (Function) :=
  fun {A B S T} _ f s =>
    t.traverse f s

/-- Convert a profunctor optic to a traversal. -/
def ofOptic (o : Optic Traversing (Function)) : Traversal S A :=
  ⟨fun {F} [Applicative F] f s => o (fun a => f a) s⟩

/-- Composition operator for traversals. -/
infixr:80 " ∘ₜ " => Traversal.comp

end Traversal

end Optics
