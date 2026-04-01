/-
# Concrete Prism Implementation
-/

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav

namespace Optics

/-- `matchS` avoids the reserved name `match`. -/
structure Prism (S A : Type u) where
  matchS : S → A ⊕ S
  build : A → S

namespace Prism

def preview (p : Prism S A) : S → Option A :=
  fun s => match p.matchS s with
    | Sum.inl a => some a
    | Sum.inr _ => none

def comp (p1 : Prism S A) (p2 : Prism A B) : Prism S B :=
  ⟨fun s =>
      match p1.matchS s with
      | Sum.inl a =>
          match p2.matchS a with
          | Sum.inl b => Sum.inl b
          | Sum.inr a' => Sum.inr (p1.build a')
      | Sum.inr s' => Sum.inr s',
   fun b => p1.build (p2.build b)⟩

def match_build (p : Prism S A) : Prop :=
  ∀ a, p.matchS (p.build a) = Sum.inl a

def build_match (p : Prism S A) : Prop :=
  ∀ (s : S) (a : A), p.matchS s = Sum.inl a → p.build a = s

def no_match_id (p : Prism S A) : Prop :=
  ∀ (s s' : S), p.matchS s = Sum.inr s' → s' = s

def WellFormed (p : Prism S A) : Prop :=
  match_build p ∧ build_match p ∧ no_match_id p

def toOptic (p : Prism S A) : Optic (fun X Y => X → Y) S S A A :=
  fun f => fun s => match p.matchS s with
    | Sum.inl a => p.build (f a)
    | Sum.inr s' => s'

infixl:80 " ∘ₚ " => comp

end Prism

end Optics
