/-
# Composition and Law Preservation
-/

import Optics.Concrete.Lens
import Optics.Concrete.Prism
import Optics.Concrete.Traversal

namespace Optics

def lens_prism_comp {S A B : Type u} (l : Lens S A) (p : Prism A B) (default_b : B) : Lens S B :=
  ⟨fun s =>
      match p.matchS (l.get s) with
      | Sum.inl b => b
      | Sum.inr _ => default_b,
   fun s b => l.set s (p.build b)⟩

def prism_lens_comp {S A B : Type u} (p : Prism S A) (l : Lens A B) (f : B → A) : Prism S B :=
  ⟨fun s => match p.matchS s with
      | Sum.inl a => Sum.inl (l.get a)
      | Sum.inr s' => Sum.inr s',
   fun b => p.build (f b)⟩

def lens_traversal_comp {S A B : Type u} (l : Lens S A) (t : Traversal A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    Functor.map (l.set s) (t.traverse f (l.get s))⟩

def traversal_lens_comp {S A B : Type u} (t : Traversal S A) (l : Lens A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    t.traverse (fun a => Functor.map (l.set a) (f (l.get a))) s⟩

def prism_traversal_comp {S A B : Type u} (p : Prism S A) (t : Traversal A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    match p.matchS s with
    | Sum.inl a => Functor.map p.build (t.traverse f a)
    | Sum.inr s' => pure s'⟩

def traversal_prism_comp {S A B : Type u} (t : Traversal S A) (p : Prism A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    t.traverse (fun a =>
      match p.matchS a with
      | Sum.inl b => Functor.map p.build (f b)
      | Sum.inr _ => pure a) s⟩

theorem lens_comp_preserves_laws {S A B : Type u} (l1 : Lens S A) (l2 : Lens A B)
    (h1 : Lens.WellFormed l1) (h2 : Lens.WellFormed l2) :
    Lens.WellFormed (l1 ∘ₗ l2) :=
  Lens.comp_preserves_laws l1 l2 h1 h2

theorem traversal_comp_preserves_laws {S A B : Type u} (t1 : Traversal S A) (t2 : Traversal A B)
    (_h1 : Traversal.WellFormed t1) (_h2 : Traversal.WellFormed t2) :
    Traversal.WellFormed (t1 ∘ₜ t2) := by
  simp [Traversal.WellFormed, Traversal.identity_law, Traversal.composition_law, Traversal.naturality_law]

end Optics
