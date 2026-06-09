/-
# Basic Traversal Tests
-/

import Optics
import Optics.Experimental
import tests.Common

open Optics

theorem listTraversal_identity : Traversal.identity_law (listTraversal : Traversal (List Nat) Nat) := by
  trivial

theorem listTraversal_composition : Traversal.composition_law (listTraversal : Traversal (List Nat) Nat) := by
  trivial

theorem listTraversal_naturality : Traversal.naturality_law (listTraversal : Traversal (List Nat) Nat) := by
  trivial

theorem listStringTraversal_wellFormed : Traversal.WellFormed (listTraversal : Traversal (List String) String) := by
  trivial

#eval Id.run do listTraversal.traverse (fun x => pure (x + 1)) [1, 2, 3]
#eval listTraversal.traverse (fun x => some (x + 1)) [1, 2, 3]
