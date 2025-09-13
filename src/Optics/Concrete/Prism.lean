/-!
# Concrete Prism Implementation

This module implements the concrete Prism structure with laws and isomorphisms
to profunctor optics.
-/

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav

namespace Optics

/-- A prism focuses on a part that may or may not exist. -/
structure Prism (S A : Type u) where
  /-- Try to extract the focused value, returning either the value or the original structure. -/
  match : S → A ⊕ S

  /-- Build a structure from the focused value. -/
  build : A → S

namespace Prism

/-- Create a prism from match and build functions. -/
def mk (match : S → A ⊕ S) (build : A → S) : Prism S A :=
  ⟨match, build⟩

/-- Preview the focused value if it exists. -/
def preview (p : Prism S A) : S → Option A :=
  fun s => match p.match s with
  | Sum.inl a => some a
  | Sum.inr _ => none

/-- Compose two prisms. -/
def comp (p₁ : Prism S A) (p₂ : Prism A B) : Prism S B :=
  ⟨fun s => match p₁.match s with
    | Sum.inl a => p₂.match a
    | Sum.inr s' => Sum.inr s',
   p₂.build ∘ p₁.build⟩

/-- Prism laws -/

/-- The match-build law: matching a built value returns the original input. -/
def match_build (p : Prism S A) : Prop :=
  ∀ a, p.match (p.build a) = Sum.inl a

/-- The build-match law: building a matched value returns the original structure. -/
def build_match (p : Prism S A) : Prop :=
  ∀ s, p.match s = Sum.inl a → p.build a = s

/-- The no-match law: a non-matching case returns the original structure. -/
def no_match_id (p : Prism S A) : Prop :=
  ∀ s, p.match s = Sum.inr s' → s' = s

/-- A prism is well-formed if it satisfies all prism laws. -/
def WellFormed (p : Prism S A) : Prop :=
  match_build p ∧ build_match p ∧ no_match_id p

/-- Isomorphism between prisms and profunctor optics -/

/-- Convert a prism to a profunctor optic. -/
def toOptic (p : Prism S A) : Optic Choice (Function) :=
  fun {A B S T} _ f s =>
    match p.match s with
    | Sum.inl a => f a
    | Sum.inr s' => s'

/-- Convert a profunctor optic to a prism. -/
def ofOptic (o : Optic Choice (Function)) : Prism S A :=
  ⟨fun s => o (fun a => Sum.inl a) s, fun a => o (fun _ => a) (o (fun _ => a) ())⟩

/-- Composition operator for prisms. -/
infixr:80 " ∘ₚ " => Prism.comp

end Prism

end Optics
