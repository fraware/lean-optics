/-
# Composition Test Main
-/

import tests.Compose.Basic
import tests.Runner

def main : IO UInt32 := do
  IO.println "Running Composition Tests..."
  let runner ← runCompositionTests
  runner.report
  if runner.passed == runner.total then return 0 else return 1
