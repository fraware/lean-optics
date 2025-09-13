/-!
# Optic Laws Tactic

This module implements the optic_laws! tactic for automatically discharging
standard law obligations for lenses, prisms, and traversals.
-/

import Lean
import Optics.Tactics.LocalSimp
import Optics.Telemetry.Timing

namespace Optics

/-- Configuration options for the optic_laws! tactic. -/
structure OpticConfig where
  maxSteps : Nat := 256
  timeoutMs : Nat := 200
  trace : Bool := false
  localSimpSet : Option Lean.SimpSet := none

/-- Default configuration. -/
def defaultConfig : OpticConfig := {}

/-- The optic_laws! tactic implementation. -/
elab "optic_laws!" : tactic => do
  let goal ← Lean.getMainGoal
  let config := defaultConfig

  -- Detect the type of optic law we're trying to prove
  let goalType ← Lean.instantiateMVars (← goal.getType)

  -- Classify goal for telemetry
  let goalKind := Optics.Telemetry.classifyGoal goalType

  -- Start timing
  Optics.Telemetry.startTiming "optic_laws!" goalKind

  -- Apply appropriate proof strategy based on goal type
  try
    match goalType with
    | .app (.const ``Lens.get_put _) _ =>
      -- Lens get_put law: get (set s a) = a
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.ext goal)
    | .app (.const ``Lens.put_get _) _ =>
      -- Lens put_get law: set s (get s) = s
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.ext goal)
    | .app (.const ``Lens.put_put _) _ =>
      -- Lens put_put law: set (set s a) b = set s b
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.ext goal)
    | .app (.const ``Prism.match_build _) _ =>
      -- Prism match_build law: match (build a) = Sum.inl a
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.cases goal)
    | .app (.const ``Prism.build_match _) _ =>
      -- Prism build_match law: match s = Sum.inl a → build a = s
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.cases goal)
    | .app (.const ``Prism.no_match_id _) _ =>
      -- Prism no_match_id law: match s = Sum.inr s' → s' = s
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.cases goal)
    | .app (.const ``Traversal.identity_law _) _ =>
      -- Traversal identity law: traverse (pure ∘ id) = pure
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.ext goal)
    | .app (.const ``Traversal.composition_law _) _ =>
      -- Traversal composition law
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.ext goal)
    | .app (.const ``Traversal.naturality_law _) _ =>
      -- Traversal naturality law
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.ext goal)
    | _ =>
      -- Fallback: try general simplification
      Lean.Tactic.simpGoal goal (config.localSimpSet.getD opticSimpSet)
      Lean.Tactic.tryTactic (Lean.Tactic.ext goal)

    -- Record successful completion
    Optics.Telemetry.endTiming true
  catch e =>
    -- Record failure
    Optics.Telemetry.endTiming false
    throw e

end Optics
