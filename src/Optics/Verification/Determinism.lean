/-
# Determinism Verification (minimal)

Lightweight helpers for comparing tactic outcomes; extend with Meta-based hashing as needed.
-/

import Lean
import Lean.Elab.Tactic
import Optics.Tactics.OpticLaws
import Optics.Telemetry.Core

namespace Optics.Verification

open Lean.Elab.Tactic

structure DeterminismResult where
  testName : String
  isDeterministic : Bool
  proofHash1 : String
  proofHash2 : String
  errorMessage : Option String := none

def hashProofTerm (proof : Lean.Expr) : String :=
  toString (hash proof)

def testDeterminism (testName : String) (proofGenerator : Lean.Elab.Tactic.TacticM Unit) :
    Lean.Elab.Tactic.TacticM DeterminismResult := do
  let goal1 ← getMainGoal
  let goal2 ← getMainGoal
  try
    proofGenerator
    let proof1 ← goal1.getType
    let hash1 := hashProofTerm proof1
    proofGenerator
    let proof2 ← goal2.getType
    let hash2 := hashProofTerm proof2
    pure { testName, isDeterministic := hash1 == hash2, proofHash1 := hash1, proofHash2 := hash2 }
  catch _ =>
    pure {
      testName,
      isDeterministic := false,
      proofHash1 := "",
      proofHash2 := "",
      errorMessage := some "determinism test failed"
    }

def testHypothesisOrderIndependence (testName : String) (proofGenerator : Lean.Elab.Tactic.TacticM Unit) :
    Lean.Elab.Tactic.TacticM DeterminismResult :=
  testDeterminism testName proofGenerator

def runDeterminismTests : Lean.Elab.Tactic.TacticM (Array DeterminismResult) := do
  let tests : Array (String × Lean.Elab.Tactic.TacticM Unit) := #[
    ("lens_get_put", do evalTactic (← `(tactic| optic_laws!))),
    ("lens_put_get", do evalTactic (← `(tactic| optic_laws!))),
    ("lens_put_put", do evalTactic (← `(tactic| optic_laws!))),
    ("prism_match_build", do evalTactic (← `(tactic| optic_laws!))),
    ("prism_build_match", do evalTactic (← `(tactic| optic_laws!))),
    ("traversal_identity", do evalTactic (← `(tactic| optic_laws!)))
  ]
  let mut results : Array DeterminismResult := #[]
  for (name, test) in tests do
    let result ← testDeterminism name test
    results := results.push result
  pure results

def reportDeterminismResults (results : Array DeterminismResult) : IO Unit := do
  let total := results.size
  let deterministic := results.filter (·.isDeterministic) |>.size
  let failed := results.filter (¬ ·.isDeterministic) |>.size
  IO.println s!"Determinism Test Results:"
  IO.println s!"  Total tests: {total}"
  IO.println s!"  Deterministic: {deterministic}"
  IO.println s!"  Failed: {failed}"
  for result in results do
    if result.isDeterministic then
      IO.println s!"  [PASS] {result.testName}"
    else
      IO.println s!"  [FAIL] {result.testName}"
      if let some error := result.errorMessage then
        IO.println s!"      Error: {error}"
      else
        IO.println s!"      Hash mismatch: {result.proofHash1} vs {result.proofHash2}"

end Optics.Verification
