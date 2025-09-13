/-!
# Prism Test Main

This is the main entry point for running prism tests.
-/

import Tests.Prism.Basic
import Tests.TestRunner

def main : IO Unit := do
  IO.println "Running Prism Tests..."
  let runner ← runPrismTests
  runner.report

  if runner.passed == runner.total then
    IO.println "All prism tests passed! 🎉"
    System.Exit.exit 0
  else
    IO.println "Some prism tests failed! ❌"
    System.Exit.exit 1
