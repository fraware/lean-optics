/-
# Traversal Test Main
-/

import tests.Traversal.Basic
import tests.Runner

def main : IO UInt32 := do
  IO.println "Running Traversal Tests..."
  let runner ← runTraversalTests
  runner.report
  if runner.passed == runner.total then return 0 else return 1
