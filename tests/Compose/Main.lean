/-!
# Composition Test Main

This is the main entry point for running composition tests.
-/

import Tests.Compose.Basic
import Tests.TestRunner

def main : IO Unit := do
  IO.println "Running Composition Tests..."
  let runner ← runCompositionTests
  runner.report

  if runner.passed == runner.total then
    IO.println "All composition tests passed! 🎉"
    System.Exit.exit 0
  else
    IO.println "Some composition tests failed! ❌"
    System.Exit.exit 1
