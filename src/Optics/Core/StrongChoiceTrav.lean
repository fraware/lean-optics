/-
# Strong, Choice, and Traversing Classes

This module defines the Strong, Choice, and Traversing classes that extend
profunctors with additional structure for lenses, prisms, and traversals.
-/

import Optics.Core.Profunctor

namespace Optics

/-- Strong profunctor: product strength (used for lenses). -/
class Strong (P : Type u → Type u → Type u) [Profunctor P] where
  first' : {A B C : Type u} → P A B → P (A × C) (B × C)
  second' : {A B C : Type u} → P A B → P (C × A) (C × B)

instance strongFunction : Strong (fun A B => A → B) where
  first' f := fun (a, c) => (f a, c)
  second' f := fun (c, a) => (c, f a)

/-- Choice profunctor: coproduct strength (used for prisms). -/
class Choice (P : Type u → Type u → Type u) [Profunctor P] where
  left' : {A B C : Type u} → P A B → P (A ⊕ C) (B ⊕ C)
  right' : {A B C : Type u} → P A B → P (C ⊕ A) (C ⊕ B)

instance choiceFunction : Choice (fun A B => A → B) where
  left' f := fun s => match s with
    | Sum.inl a => Sum.inl (f a)
    | Sum.inr c => Sum.inr c
  right' f := fun s => match s with
    | Sum.inl c => Sum.inl c
    | Sum.inr a => Sum.inr (f a)

/-- Traversing profunctor marker (minimal; extend as needed). -/
class Traversing (P : Type u → Type u → Type u) [Profunctor P] where
  /-- Placeholder field so the class is inhabited; expand with real traverse when needed. -/
  trivial : Unit := ()

instance traversingFunction : Traversing (fun A B => A → B) where

end Optics
