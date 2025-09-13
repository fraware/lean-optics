/-!
# Core Profunctor Classes

This module defines the core profunctor classes and their associated laws.
-/

namespace Optics

/-- A profunctor is a bifunctor that is contravariant in its first argument
    and covariant in its second argument. -/
class Profunctor (P : Type u → Type v → Type w) where
  /-- The fundamental profunctor operation that maps both arguments. -/
  dimap : {A B C D : Type u} → (C → A) → (B → D) → P A B → P C D

  /-- Identity law: dimap id id = id -/
  dimap_id : ∀ {A B : Type u} (p : P A B), dimap id id p = p

  /-- Composition law: dimap (f ∘ g) (h ∘ i) = dimap g h ∘ dimap f i -/
  dimap_comp : ∀ {A B C D E F : Type u} (f : C → A) (g : B → D) (h : E → C) (i : D → F) (p : P A B),
    dimap (f ∘ h) (i ∘ g) p = dimap h i (dimap f g p)

namespace Profunctor

/-- The identity profunctor. -/
instance : Profunctor (Function) where
  dimap f g h := g ∘ h ∘ f
  dimap_id _ := rfl
  dimap_comp _ _ _ _ _ := rfl

/-- Profunctors are closed under composition. -/
instance [Profunctor P] [Profunctor Q] : Profunctor (P ∘ Q) where
  dimap f g pq := dimap f g pq
  dimap_id pq := by simp [dimap_id]
  dimap_comp f g h i pq := by simp [dimap_comp]

end Profunctor

/-- A profunctor optic is a higher-rank function that transforms profunctors. -/
abbrev Optic (C : Type → Type → Type) (P : Type → Type → Type) [Profunctor P] :=
  ∀ {A B S T : Type}, C P → P A B → P S T

end Optics
