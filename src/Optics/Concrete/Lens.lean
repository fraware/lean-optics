/-!
# Concrete Lens Implementation

This module implements the concrete Lens structure with laws and isomorphisms
to profunctor optics.
-/

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav

namespace Optics

/-- A lens focuses on a part of a larger structure. -/
structure Lens (S A : Type u) where
  /-- Extract the focused value from the structure. -/
  get : S → A

  /-- Update the focused value in the structure. -/
  set : S → A → S

namespace Lens

/-- Create a lens from get and set functions. -/
def mk (get : S → A) (set : S → A → S) : Lens S A :=
  ⟨get, set⟩

/-- Apply a function to the focused value. -/
def over (l : Lens S A) (f : A → A) : S → S :=
  fun s => l.set s (f (l.get s))

/-- Set the focused value using a monadic computation. -/
def setM {M : Type u → Type v} [Monad M] (l : Lens S A) (mset : A → M A) : S → M S :=
  fun s => do
    let a ← mset (l.get s)
    return l.set s a

/-- Compose two lenses. -/
def comp (l₁ : Lens S A) (l₂ : Lens A B) : Lens S B :=
  ⟨l₂.get ∘ l₁.get, fun s b => l₁.set s (l₂.set (l₁.get s) b)⟩

/-- Lens laws -/

/-- The get-put law: getting after setting returns the set value. -/
def get_put (l : Lens S A) : Prop :=
  ∀ s a, l.get (l.set s a) = a

/-- The put-get law: setting to the current value leaves the structure unchanged. -/
def put_get (l : Lens S A) : Prop :=
  ∀ s, l.set s (l.get s) = s

/-- The put-put law: consecutive sets overwrite the previous value. -/
def put_put (l : Lens S A) : Prop :=
  ∀ s a b, l.set (l.set s a) b = l.set s b

/-- A lens is well-formed if it satisfies all lens laws. -/
def WellFormed (l : Lens S A) : Prop :=
  get_put l ∧ put_get l ∧ put_put l

/-- Isomorphism between lenses and profunctor optics -/

/-- Convert a lens to a profunctor optic. -/
def toOptic (l : Lens S A) : Optic Strong (Function) :=
  fun {A B S T} _ p (s : S) =>
    let a := l.get s
    let b := p a
    l.set s b

/-- Convert a profunctor optic to a lens. -/
def ofOptic (o : Optic Strong (Function)) : Lens S A :=
  ⟨fun s => o (fun a => a) s, fun s a => o (fun _ => a) s⟩

/-- The isomorphism is total. -/
theorem toOptic_ofOptic (o : Optic Strong (Function)) :
  toOptic (ofOptic o) = o := by
  ext s
  simp [toOptic, ofOptic]

theorem ofOptic_toOptic (l : Lens S A) :
  ofOptic (toOptic l) = l := by
  cases l
  simp [toOptic, ofOptic]

/-- Composition operator for lenses. -/
infixr:80 " ∘ₗ " => Lens.comp

/-- Lens composition preserves laws. -/
theorem comp_preserves_laws (l₁ : Lens S A) (l₂ : Lens A B)
  (h₁ : WellFormed l₁) (h₂ : WellFormed l₂) :
  WellFormed (l₂ ∘ₗ l₁) := by
  constructor
  · -- get_put
    intro s b
    simp [comp, get_put]
    have h₁_get_put := h₁.1
    have h₂_get_put := h₂.1
    simp [h₁_get_put, h₂_get_put]
  · constructor
    · -- put_get
      intro s
      simp [comp, put_get]
      have h₁_put_get := h₁.2.1
      have h₂_put_get := h₂.2.1
      simp [h₁_put_get, h₂_put_get]
    · -- put_put
      intro s a b
      simp [comp, put_put]
      have h₁_put_put := h₁.2.2
      have h₂_put_put := h₂.2.2
      simp [h₁_put_put, h₂_put_put]

end Lens

end Optics
