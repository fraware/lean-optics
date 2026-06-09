/-
# Full test suite entry point
-/

import tests.Runner

def main : IO UInt32 := do
  IO.println "Starting Lean Optics Test Suite..."
  IO.println ""
  let totalRunner ← runAllTests
  totalRunner.report
  if totalRunner.passed == totalRunner.total then
    IO.println "All tests passed!"
    return 0
  else
    IO.println "Some tests failed!"
    return 1
