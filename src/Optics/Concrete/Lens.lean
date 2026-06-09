/-
# Concrete Lens Implementation

Provides both a proof-free `Lens` (for macros and backward compatibility) and a
`LawfulLens` structure carrying the three standard lens laws inline.
-/

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav

namespace Optics

/-- Lens without bundled laws (used by `lens!` and manual construction). -/
structure Lens (S A : Type u) where
  get : S → A
  set : S → A → S

/--
Minimal lawful lens for verified state access (CSLib upstream candidate).

Law names follow the `get`/`set` vocabulary: `get_set`, `set_get`, `set_set`.
-/
structure LawfulLens (S A : Type u) extends Lens S A where
  get_set : ∀ s a, get (set s a) = a
  set_get : ∀ s, set s (get s) = s
  set_set : ∀ s a b, set (set s a) b = set s b

namespace Lens

def over (l : Lens S A) (f : A → A) : S → S :=
  fun s => l.set s (f (l.get s))

def setM {M : Type u → Type v} [Monad M] (l : Lens S A) (mset : A → M A) : S → M S :=
  fun s => do
    let a ← mset (l.get s)
    return l.set s a

def comp (l1 : Lens S A) (l2 : Lens A B) : Lens S B :=
  ⟨l2.get ∘ l1.get, fun s b => l1.set s (l2.set (l1.get s) b)⟩

/-- `get (set s a) = a` -/
def get_put (l : Lens S A) : Prop :=
  ∀ s a, l.get (l.set s a) = a

/-- `set s (get s) = s` -/
def put_get (l : Lens S A) : Prop :=
  ∀ s, l.set s (l.get s) = s

/-- `set (set s a) b = set s b` -/
def put_put (l : Lens S A) : Prop :=
  ∀ s a b, l.set (l.set s a) b = l.set s b

/-- Alias for `get_put` using `get`/`set` law naming. -/
abbrev get_set (l : Lens S A) : Prop := get_put l

/-- Alias for `put_get` using `get`/`set` law naming. -/
abbrev set_get (l : Lens S A) : Prop := put_get l

/-- Alias for `put_put` using `get`/`set` law naming. -/
abbrev set_set (l : Lens S A) : Prop := put_put l

def WellFormed (l : Lens S A) : Prop :=
  get_put l ∧ put_get l ∧ put_put l

/-- Every `LawfulLens` satisfies `WellFormed` for its underlying `Lens`. -/
theorem lawful_wellFormed (l : LawfulLens S A) : WellFormed l.toLens :=
  ⟨l.get_set, l.set_get, l.set_set⟩

instance : Coe (LawfulLens S A) (Lens S A) := ⟨fun l => l.toLens⟩

/-- Build a proof-free lens from getter and setter. -/
def of (get : S → A) (set : S → A → S) : Lens S A :=
  { get, set }

def mkLawful (get : S → A) (set : S → A → S)
    (get_set : ∀ s a, get (set s a) = a)
    (set_get : ∀ s, set s (get s) = s)
    (set_set : ∀ s a b, set (set s a) b = set s b) : LawfulLens S A :=
  { get, set, get_set, set_get, set_set }

def toOptic (l : Lens S A) : Optic (fun X Y => X → Y) S S A A :=
  fun p => fun s => l.set s (p (l.get s))

infixl:80 " ∘ₗ " => comp

@[simp] theorem get_set_eq {l : Lens S A} {s : S} {a : A} (h : get_put l) :
    l.get (l.set s a) = a :=
  h s a

@[simp] theorem set_get_eq {l : Lens S A} {s : S} (h : put_get l) :
    l.set s (l.get s) = s :=
  h s

@[simp] theorem set_set_eq {l : Lens S A} {s : S} {a b : A} (h : put_put l) :
    l.set (l.set s a) b = l.set s b :=
  h s a b

@[simp] theorem lawful_get_set (l : LawfulLens S A) (s : S) (a : A) :
    l.get (l.set s a) = a :=
  l.get_set s a

@[simp] theorem lawful_set_get (l : LawfulLens S A) (s : S) :
    l.set s (l.get s) = s :=
  l.set_get s

@[simp] theorem lawful_set_set (l : LawfulLens S A) (s : S) (a b : A) :
    l.set (l.set s a) b = l.set s b :=
  l.set_set s a b

theorem comp_preserves_laws {S A B : Type u} (l1 : Lens S A) (l2 : Lens A B)
    (h1 : WellFormed l1) (h2 : WellFormed l2) :
    WellFormed (l1 ∘ₗ l2) := by
  rcases h1 with ⟨hgp1, hpg1, hpp1⟩
  rcases h2 with ⟨hgp2, hpg2, hpp2⟩
  refine ⟨?_, ?_, ?_⟩
  · intro s b
    dsimp [comp]
    rw [hgp1, hgp2]
  · intro s
    dsimp [comp]
    rw [hpg2, hpg1]
  · intro s a b
    dsimp [comp]
    rw [hgp1, hpp2, hpp1]

end Lens

end Optics
