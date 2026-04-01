/-
# Concrete Lens Implementation
-/

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav

namespace Optics

structure Lens (S A : Type u) where
  get : S → A
  set : S → A → S

namespace Lens

def over (l : Lens S A) (f : A → A) : S → S :=
  fun s => l.set s (f (l.get s))

def setM {M : Type u → Type v} [Monad M] (l : Lens S A) (mset : A → M A) : S → M S :=
  fun s => do
    let a ← mset (l.get s)
    return l.set s a

def comp (l1 : Lens S A) (l2 : Lens A B) : Lens S B :=
  ⟨l2.get ∘ l1.get, fun s b => l1.set s (l2.set (l1.get s) b)⟩

def get_put (l : Lens S A) : Prop :=
  ∀ s a, l.get (l.set s a) = a

def put_get (l : Lens S A) : Prop :=
  ∀ s, l.set s (l.get s) = s

def put_put (l : Lens S A) : Prop :=
  ∀ s a b, l.set (l.set s a) b = l.set s b

def WellFormed (l : Lens S A) : Prop :=
  get_put l ∧ put_get l ∧ put_put l

def toOptic (l : Lens S A) : Optic (fun X Y => X → Y) S S A A :=
  fun p => fun s => l.set s (p (l.get s))

infixl:80 " ∘ₗ " => comp

theorem comp_preserves_laws {S A B : Type u} (l1 : Lens S A) (l2 : Lens A B)
    (_h1 : WellFormed l1) (_h2 : WellFormed l2) :
    WellFormed (l1 ∘ₗ l2) := by
  sorry

end Lens

end Optics
