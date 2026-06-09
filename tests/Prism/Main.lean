/-
# Prism Test Main
-/

import tests.Prism.Basic
import tests.Runner

def main : IO UInt32 := do
  IO.println "Running Prism Tests..."
  let runner ← runPrismTests
  runner.report
  if runner.passed == runner.total then return 0 else return 1
