/-!
# Lens Test Main

This is the main entry point for running lens tests.
-/

import Tests.Lens.Basic
import Tests.TestRunner

def main : IO Unit := do
  IO.println "Running Lens Tests..."
  let runner ← runLensTests
  runner.report

  if runner.passed == runner.total then
    IO.println "All lens tests passed! 🎉"
    System.Exit.exit 0
  else
    IO.println "Some lens tests failed! ❌"
    System.Exit.exit 1
