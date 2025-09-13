/-!
# Composition and Law Preservation

This module provides composition operators and proves that composition
preserves laws for all optic types.
-/

import Optics.Concrete.Lens
import Optics.Concrete.Prism
import Optics.Concrete.Traversal

namespace Optics

/-- Mixed composition via profunctor encoding -/

/-- Compose a lens with a prism.
    This creates a lens that focuses on B through the intermediate A.
    When the prism fails to match, we need a default B value. -/
def lens_prism_comp {S A B : Type u} (l : Lens S A) (p : Prism A B) (default_b : B) : Lens S B :=
  ⟨fun s =>
    match p.match (l.get s) with
    | Sum.inl b => b
    | Sum.inr _ => default_b,  -- fallback to default B value
   fun s b => l.set s (p.build b)⟩

/-- Compose a prism with a lens.
    Note: This composition requires a function to convert B back to A,
    as lenses only provide A → B mapping, not B → A. -/
def prism_lens_comp {S A B : Type u} (p : Prism S A) (l : Lens A B) (f : B → A) : Prism S B :=
  ⟨fun s => match p.match s with
    | Sum.inl a => Sum.inl (l.get a)
    | Sum.inr s' => Sum.inr s',
   fun b => p.build (f b)⟩

/-- Compose a lens with a traversal. -/
def lens_traversal_comp {S A B : Type u} (l : Lens S A) (t : Traversal A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    fmap (l.set s) (t.traverse f (l.get s))⟩

/-- Compose a traversal with a lens. -/
def traversal_lens_comp {S A B : Type u} (t : Traversal S A) (l : Lens A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    t.traverse (fun a => fmap (l.set a) (f (l.get a))) s⟩

/-- Compose a prism with a traversal. -/
def prism_traversal_comp {S A B : Type u} (p : Prism S A) (t : Traversal A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    match p.match s with
    | Sum.inl a => fmap p.build (t.traverse f a)
    | Sum.inr s' => pure s'⟩

/-- Compose a traversal with a prism. -/
def traversal_prism_comp {S A B : Type u} (t : Traversal S A) (p : Prism A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    t.traverse (fun a =>
      match p.match a with
      | Sum.inl b => f b
      | Sum.inr _ => pure a) s⟩

/-- Law preservation theorems -/

/-- Lens composition preserves laws. -/
theorem lens_comp_preserves_laws {S A B : Type u} (l₁ : Lens S A) (l₂ : Lens A B)
  (h₁ : Lens.WellFormed l₁) (h₂ : Lens.WellFormed l₂) :
  Lens.WellFormed (l₂ ∘ₗ l₁) :=
  Lens.comp_preserves_laws l₁ l₂ h₁ h₂

/-- Prism composition preserves laws. -/
theorem prism_comp_preserves_laws {S A B : Type u} (p₁ : Prism S A) (p₂ : Prism A B)
  (h₁ : Prism.WellFormed p₁) (h₂ : Prism.WellFormed p₂) :
  Prism.WellFormed (p₂ ∘ₚ p₁) := by
  constructor
  · -- match_build
    intro b
    simp [Prism.comp, Prism.match_build]
    have h₁_match_build := h₁.1
    have h₂_match_build := h₂.1
    simp [h₁_match_build, h₂_match_build]
  · constructor
    · -- build_match
      intro s h
      simp [Prism.comp, Prism.build_match] at h
      have h₁_build_match := h₁.2.1
      have h₂_build_match := h₂.2.1
      cases h with
      | inl h' => simp [h₁_build_match, h₂_build_match, h']
      | inr h' => simp [h₁_build_match, h₂_build_match, h']
    · -- no_match_id
      intro s h
      simp [Prism.comp, Prism.no_match_id] at h
      have h₁_no_match_id := h₁.2.2
      have h₂_no_match_id := h₂.2.2
      cases h with
      | inl h' => simp [h₁_no_match_id, h₂_no_match_id, h']
      | inr h' => simp [h₁_no_match_id, h₂_no_match_id, h']

/-- Traversal composition preserves laws. -/
theorem traversal_comp_preserves_laws {S A B : Type u} (t₁ : Traversal S A) (t₂ : Traversal A B)
  (h₁ : Traversal.WellFormed t₁) (h₂ : Traversal.WellFormed t₂) :
  Traversal.WellFormed (t₂ ∘ₜ t₁) := by
  constructor
  · -- identity_law
    intro s
    simp [Traversal.comp, Traversal.identity_law]
    have h₁_identity := h₁.1
    have h₂_identity := h₂.1
    simp [h₁_identity, h₂_identity]
  · constructor
    · -- composition_law
      intro F G _ _ f g s
      simp [Traversal.comp, Traversal.composition_law]
      have h₁_composition := h₁.2.1
      have h₂_composition := h₂.2.1
      simp [h₁_composition, h₂_composition]
    · -- naturality_law
      intro F G _ _ f g h s
      simp [Traversal.comp, Traversal.naturality_law]
      have h₁_naturality := h₁.2.2
      have h₂_naturality := h₂.2.2
      simp [h₁_naturality, h₂_naturality]

end Optics
