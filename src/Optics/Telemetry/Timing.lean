/-
# Timing Instrumentation for Optics Tactics

This module provides timing instrumentation for the optic_laws! tactic
and other optics operations.
-/

import Lean
import Optics.Telemetry.Core

namespace Optics.Telemetry

/-- Timing context for tracking tactic execution -/
structure TimingContext where
  tacticName : String
  goalKind : String
  startTime : Nat
  success : Bool := false

initialize timingContextRef : IO.Ref (Option TimingContext) ← IO.mkRef none

/-- Start timing a tactic -/
def startTiming (tacticName : String) (goalKind : String) : IO Unit := do
  let ts ← getTimestamp
  let ctx := { tacticName, goalKind, startTime := ts }
  timingContextRef.set (some ctx)
  recordTacticStart tacticName goalKind

/-- End timing a tactic -/
def endTiming (success : Bool := true) : IO Unit := do
  let ctx? ← timingContextRef.get
  if let some ctx := ctx? then
    let ts ← getTimestamp
    let duration := ts - ctx.startTime
    recordTacticEnd ctx.tacticName ctx.goalKind duration success
    timingContextRef.set none

/-- Execute a tactic with timing -/
def withTiming {α} (tacticName : String) (goalKind : String) (action : IO α) : IO α := do
  startTiming tacticName goalKind
  try
    let result ← action
    endTiming true
    pure result
  catch e =>
    endTiming false
    recordError "tactic_failure" s!"{tacticName} failed: {e}"
    throw e

/-- Classify goal type for telemetry -/
def classifyGoal (goal : Lean.Expr) : String :=
  if goal.isAppOfArity `Lens 2 then "lens"
  else if goal.isAppOfArity `Prism 2 then "prism"
  else if goal.isAppOfArity `Traversal 2 then "traversal"
  else if goal.isAppOfArity `Strong 1 then "strong"
  else if goal.isAppOfArity `Choice 1 then "choice"
  else if goal.isAppOfArity `Traversing 1 then "traversing"
  else if goal.isAppOfArity `Profunctor 1 then "profunctor"
  else "unknown"

/-- Get Lean version string -/
def getLeanVersion : IO String :=
  return Lean.versionString

/-- Get mathlib version (if available) -/
def getMathlibVersion : IO String := do
  try
    let manifest ← IO.FS.readFile "lake-manifest.json"
    pure (if (manifest.splitOn "batteries").length > 1 then "pinned (see lake-manifest.json)" else "unavailable")
  catch _ =>
    pure "unavailable"

/-- Initialize telemetry with version information -/
def initializeTelemetry : IO Unit := do
  let leanVer ← getLeanVersion
  let mathlibVer ← getMathlibVersion
  recordVersionInfo leanVer mathlibVer

end Optics.Telemetry
