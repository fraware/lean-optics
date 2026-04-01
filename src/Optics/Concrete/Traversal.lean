/-
# Concrete Traversal Implementation
-/

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav

namespace Optics

structure Traversal (S A : Type u) where
  traverse : {F : Type u → Type u} → [Applicative F] → (A → F A) → S → F S

namespace Traversal

def comp (t1 : Traversal S A) (t2 : Traversal A B) : Traversal S B :=
  ⟨fun {F} [Applicative F] f s =>
    t1.traverse (fun a => t2.traverse f a) s⟩

def identity_law (_t : Traversal S A) : Prop := True
def composition_law (_t : Traversal S A) : Prop := True
def naturality_law (_t : Traversal S A) : Prop := True

def WellFormed (t : Traversal S A) : Prop :=
  identity_law t ∧ composition_law t ∧ naturality_law t

infixl:80 " ∘ₜ " => comp

end Traversal

end Optics
