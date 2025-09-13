/-!
# Traversal Test Main

This is the main entry point for running traversal tests.
-/

import Tests.Traversal.Basic
import Tests.TestRunner

def main : IO Unit := do
  IO.println "Running Traversal Tests..."
  let runner ← runTraversalTests
  runner.report

  if runner.passed == runner.total then
    IO.println "All traversal tests passed! 🎉"
    System.Exit.exit 0
  else
    IO.println "Some traversal tests failed! ❌"
    System.Exit.exit 1
