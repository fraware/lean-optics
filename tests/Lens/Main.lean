/-
# Lens Test Main
-/

import tests.Lens.Basic
import tests.Runner

def main : IO UInt32 := do
  IO.println "Running Lens Tests..."
  let runner ← runLensTests
  runner.report
  if runner.passed == runner.total then return 0 else return 1
