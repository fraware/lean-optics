/-
# Core Profunctor Classes

This module defines the core profunctor classes and their associated laws.
-/

namespace Optics

/-- Profunctor: contravariant in the first type argument, covariant in the second. -/
class Profunctor (P : Type u → Type u → Type u) where
  dimap : {A B C D : Type u} → (C → A) → (B → D) → P A B → P C D
  dimap_id : ∀ {A B : Type u} (p : P A B), dimap id id p = p

namespace Profunctor

/-- Function is a profunctor via pre- and post-composition. -/
instance profunctorFunction : Profunctor (fun A B => A → B) where
  dimap f g h := g ∘ h ∘ f
  dimap_id _ := rfl

end Profunctor

/-- Profunctor section: maps `P A B` to `P S T` (Haskell-style `p a b -> p s t`). -/
abbrev Optic (P : Type u → Type u → Type u) [Profunctor P] (S T A B : Type u) : Type u :=
  P A B → P S T

end Optics
