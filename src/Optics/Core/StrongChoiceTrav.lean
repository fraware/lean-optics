/-!
# Strong, Choice, and Traversing Classes

This module defines the Strong, Choice, and Traversing classes that extend
profunctors with additional structure for lenses, prisms, and traversals.
-/

import Optics.Core.Profunctor

namespace Optics

/-- A strong profunctor can lift its first argument through products. -/
class Strong (P : Type u → Type v → Type w) [Profunctor P] where
  /-- Lift the first component of a product. -/
  first' : {A B C : Type u} → P A B → P (A × C) (B × C)

  /-- Lift the second component of a product. -/
  second' : {A B C : Type u} → P A B → P (C × A) (C × B)

  /-- Coherence laws for strong profunctors. -/
  strong_laws : ∀ {A B C D : Type u} (p : P A B) (f : A → C) (g : B → D),
    first' (dimap f g p) = dimap (Prod.map f id) (Prod.map g id) (first' p) ∧
    second' (dimap f g p) = dimap (Prod.map id f) (Prod.map id g) (second' p) ∧
    first' (first' p) = dimap (fun ((a, b), c) => (a, (b, c))) (fun (a, (b, c)) => ((a, b), c)) (second' (second' p))

namespace Strong

/-- Function is strong. -/
instance : Strong (Function) where
  first' f := fun (a, c) => (f a, c)
  second' f := fun (c, a) => (c, f a)
  strong_laws := by
    intros A B C D p f g
    constructor
    · simp [first', dimap, Prod.map]
    · constructor
      · simp [second', dimap, Prod.map]
      · simp [first', second', dimap, Prod.map]

end Strong

/-- A choice profunctor can lift its first argument through sums. -/
class Choice (P : Type u → Type v → Type w) [Profunctor P] where
  /-- Lift the first component of a sum. -/
  left' : {A B C : Type u} → P A B → P (A ⊕ C) (B ⊕ C)

  /-- Lift the second component of a sum. -/
  right' : {A B C : Type u} → P A B → P (C ⊕ A) (C ⊕ B)

  /-- Coherence laws for choice profunctors. -/
  choice_laws : ∀ {A B C D : Type u} (p : P A B) (f : A → C) (g : B → D),
    left' (dimap f g p) = dimap (Sum.map f id) (Sum.map g id) (left' p) ∧
    right' (dimap f g p) = dimap (Sum.map id f) (Sum.map id g) (right' p) ∧
    left' (left' p) = dimap (fun (a ⊕ c) ⊕ d => a ⊕ (c ⊕ d)) (fun a ⊕ (c ⊕ d) => (a ⊕ c) ⊕ d) (right' (right' p))

namespace Choice

/-- Function is choice. -/
instance : Choice (Function) where
  left' f := Sum.map f id
  right' f := Sum.map id f
  choice_laws := by
    intros A B C D p f g
    constructor
    · simp [left', dimap, Sum.map]
    · constructor
      · simp [right', dimap, Sum.map]
      · simp [left', right', dimap, Sum.map]

end Choice

/-- A traversing profunctor can lift its first argument through traversable functors. -/
class Traversing (P : Type u → Type v → Type w) [Profunctor P] where
  /-- Lift through a traversable functor. -/
  traverse' : {F : Type u → Type u} → [Applicative F] → {A B C : Type u} →
    (A → F B) → P A B → P (List A) (F (List B))

  /-- Coherence laws for traversing profunctors. -/
  traversing_laws : ∀ {F : Type u → Type u} [Applicative F] {A B C D : Type u}
    (p : P A B) (f : A → C) (g : B → D) (h : C → F D),
    traverse' h (dimap f g p) = dimap (List.map f) (map (List.map g)) (traverse' (h ∘ f) p) ∧
    traverse' (pure ∘ g) p = dimap (List.map id) (map (List.map g)) (traverse' (pure ∘ id) p) ∧
    traverse' (fun a => f <$> h a) p = dimap (List.map id) (map (List.map f)) (traverse' h p)

namespace Traversing

/-- Function is traversing. -/
instance : Traversing (Function) where
  traverse' f := fun xs => map f xs
  traversing_laws := by
    intros F _ A B C D p f g h
    constructor
    · simp [traverse', dimap, List.map, map]
    · constructor
      · simp [traverse', dimap, List.map, map, pure]
      · simp [traverse', dimap, List.map, map]

end Traversing

end Optics
