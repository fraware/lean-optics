/-
# Advanced test suite entry point
-/

import tests.Advanced.Runner

open tests.Advanced

def main : IO UInt32 := do
  IO.println "Running advanced optics golden tests..."
  let report ← runAllAdvancedTests
  report.print
  if report.passed == report.total then return 0 else return 1
