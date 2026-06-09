/-
# Basic Prism Tests
-/

import Optics
import tests.Common

open Optics Tests.Common

theorem optionPrism_match_build : Prism.match_build (optionPrism : Prism (Option Nat) Nat) := by
  intro a; simp [optionPrism]

theorem optionPrism_build_match : Prism.build_match (optionPrism : Prism (Option Nat) Nat) := by
  intro s a h
  cases s with
  | none => simp [optionPrism] at h
  | some s' => simp [optionPrism] at h; cases h; rfl

theorem optionPrism_no_match_id : Prism.no_match_id (optionPrism : Prism (Option Nat) Nat) := by
  intro s s' h
  cases s with
  | none => simp [optionPrism] at h; cases h; rfl
  | some _ => simp [optionPrism] at h

theorem optionStringPrism_wellFormed : Prism.WellFormed (optionPrism : Prism (Option String) String) := by
  refine ⟨?_, ?_, ?_⟩
  · intro a; simp [optionPrism]
  · intro s a h
    cases s with
    | none => simp [optionPrism] at h
    | some s' => simp [optionPrism] at h; cases h; rfl
  · intro s s' h
    cases s with
    | none => simp [optionPrism] at h; cases h; rfl
    | some _ => simp [optionPrism] at h

#eval optionPrism.preview (some 42)
#eval optionPrism.preview (none : Option Nat)
#eval optionPrism.build 42
