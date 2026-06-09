/-
# Basic Composition Tests
-/

import Optics
import Optics.Experimental
import tests.Common

open Optics Tests.Common

theorem streetLens'_wellFormed : Lens.WellFormed streetLens' :=
  Lens.comp_preserves_laws personAddressLens streetLens
    (Lens.lawful_wellFormed PersonWithAddress.addressLens)
    (Lens.lawful_wellFormed Address.streetLens)

def optionOptionStringPrism : Prism (Option (Option String)) String :=
  (optionPrism : Prism (Option (Option String)) (Option String)) ∘ₚ
    (optionPrism : Prism (Option String) String)

theorem optionOptionStringPrism_wellFormed : Prism.WellFormed optionOptionStringPrism := by
  refine ⟨?_, ?_, ?_⟩
  · intro a; simp [optionOptionStringPrism, Prism.comp, optionPrism]
  · intro s a h
    cases s with
    | none => simp [optionOptionStringPrism, Prism.comp, optionPrism] at h
    | some s' =>
      cases s' with
      | none => simp [optionOptionStringPrism, Prism.comp, optionPrism] at h
      | some _ => simp [optionOptionStringPrism, Prism.comp, optionPrism] at h; cases h; rfl
  · intro s s' h
    cases s with
    | none => simp [optionOptionStringPrism, Prism.comp, optionPrism] at h; cases h; rfl
    | some s₁ =>
      cases s₁ with
      | none => simp [optionOptionStringPrism, Prism.comp, optionPrism] at h; exact h.symm
      | some _ => simp [optionOptionStringPrism, Prism.comp, optionPrism] at h

def listListNatTraversal : Traversal (List (List Nat)) Nat :=
  (listTraversal : Traversal (List (List Nat)) (List Nat)) ∘ₜ
    (listTraversal : Traversal (List Nat) Nat)

theorem listListNatTraversal_wellFormed : Traversal.WellFormed listListNatTraversal :=
  traversal_comp_preserves_laws
    (listTraversal : Traversal (List (List Nat)) (List Nat))
    (listTraversal : Traversal (List Nat) Nat)
    (by trivial) (by trivial)
