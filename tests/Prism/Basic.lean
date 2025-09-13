/-!
# Basic Prism Tests

This module tests basic prism functionality and laws.
-/

import Optics

-- Test prism for Maybe
def maybePrism {A : Type} : Prism (Option A) A :=
  prism! (fun x => match x with | some a => Sum.inl a | none => Sum.inr none) some

-- Test prism laws
theorem maybePrism_match_build : Prism.match_build maybePrism := by
  intro a
  simp [maybePrism, Prism.match_build]

theorem maybePrism_build_match : Prism.build_match maybePrism := by
  intro s h
  simp [maybePrism, Prism.build_match] at h
  cases h with
  | inl h' => simp [h']
  | inr h' => simp [h']

theorem maybePrism_no_match_id : Prism.no_match_id maybePrism := by
  intro s h
  simp [maybePrism, Prism.no_match_id] at h
  cases h with
  | inl h' => simp [h']
  | inr h' => simp [h']

-- Test prism operations
#eval maybePrism.preview (some 42)  -- some 42
#eval maybePrism.preview none  -- none
#eval maybePrism.build 42  -- some 42

-- Test prism composition
def maybeStringPrism : Prism (Option String) String :=
  prism! (fun x => match x with | some s => Sum.inl s | none => Sum.inr none) some

theorem maybeStringPrism_laws : Prism.WellFormed maybeStringPrism := by
  constructor
  · -- match_build
    intro s
    simp [maybeStringPrism, Prism.match_build]
  · constructor
    · -- build_match
      intro s h
      simp [maybeStringPrism, Prism.build_match] at h
      cases h with
      | inl h' => simp [h']
      | inr h' => simp [h']
    · -- no_match_id
      intro s h
      simp [maybeStringPrism, Prism.no_match_id] at h
      cases h with
      | inl h' => simp [h']
      | inr h' => simp [h']
