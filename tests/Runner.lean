/-
# Shared runtime test runner (no `main`)
-/

import Optics
import Optics.Experimental
import tests.Common

open Optics Tests.Common

private def banner : String :=
  String.ofList (List.replicate 50 '=')

structure TestResult where
  name : String
  passed : Bool
  error : Option String

structure TestRunner where
  results : List TestResult
  total : Nat
  passed : Nat

def TestRunner.empty : TestRunner :=
  { results := [], total := 0, passed := 0 }

def TestRunner.addResult (tr : TestRunner) (name : String) (passed : Bool)
    (error : Option String := none) : TestRunner :=
  { tr with
    results := { name := name, passed := passed, error := error } :: tr.results
    total := tr.total + 1
    passed := if passed then tr.passed + 1 else tr.passed }

def TestRunner.report (tr : TestRunner) : IO Unit := do
  IO.println banner
  IO.println "LEAN OPTICS TEST SUITE REPORT"
  IO.println banner
  IO.println s!"Total Tests: {tr.total}"
  IO.println s!"Passed: {tr.passed}"
  IO.println s!"Failed: {tr.total - tr.passed}"
  IO.println s!"Success Rate: {if tr.total > 0 then (tr.passed * 100 / tr.total) else 0}%"
  IO.println ""
  if tr.total - tr.passed > 0 then
    IO.println "FAILED TESTS:"
    for result in tr.results do
      if !result.passed then
        IO.println s!"  [FAIL] {result.name}"
        if let some err := result.error then
          IO.println s!"     Error: {err}"
  else
    IO.println "ALL TESTS PASSED!"
  IO.println banner

def runLensTests : IO TestRunner := do
  let name := nameLens.get testPerson
  let runner := TestRunner.empty.addResult "Lens.get" (name == "Alice")
    (if name == "Alice" then none else some s!"Expected 'Alice', got '{name}'")
  let updatedPerson := nameLens.set testPerson "Bob"
  let runner := runner.addResult "Lens.set" (updatedPerson.name == "Bob")
    (if updatedPerson.name == "Bob" then none else some s!"Expected 'Bob', got '{updatedPerson.name}'")
  let upperPerson := nameLens.over (fun n => n.toUpper) testPerson
  return runner.addResult "Lens.over" (upperPerson.name == "ALICE")
    (if upperPerson.name == "ALICE" then none else some s!"Expected 'ALICE', got '{upperPerson.name}'")

def runPrismTests : IO TestRunner := do
  let previewSome := optionPrism.preview (some "test")
  let runner := TestRunner.empty.addResult "Prism.preview (some)" (previewSome == some "test")
    (if previewSome == some "test" then none else some s!"Expected some 'test', got '{previewSome}'")
  let previewNone := optionPrism.preview (none : Option String)
  let runner := runner.addResult "Prism.preview (none)" (previewNone == none)
    (if previewNone == none then none else some s!"Expected none, got '{previewNone}'")
  let built := optionPrism.build "test"
  return runner.addResult "Prism.build" (built == some "test")
    (if built == some "test" then none else some s!"Expected some 'test', got '{built}'")

def runTraversalTests : IO TestRunner := do
  let result := Id.run do listTraversal.traverse (fun x => pure (x + 1)) [1, 2, 3]
  let passed := result == [2, 3, 4]
  return TestRunner.empty.addResult "Traversal.traverse" passed
    (if passed then none else some s!"Expected [2, 3, 4], got '{result}'")

def runCompositionTests : IO TestRunner := do
  let street := streetLens'.get testPersonWithAddress
  let passed := street == "123 Main St"
  return TestRunner.empty.addResult "Lens Composition" passed
    (if passed then none else some s!"Expected '123 Main St', got '{street}'")

def runIntegrationTests : IO TestRunner := do
  let nameFromSome := lensPrismComp.get (some testPerson)
  let runner := TestRunner.empty.addResult "Integration: Lens-Prism (some)"
    (nameFromSome == "Alice")
    (if nameFromSome == "Alice" then none else some s!"Expected 'Alice', got '{nameFromSome}'")
  let nameFromNone := lensPrismComp.get none
  return runner.addResult "Integration: Lens-Prism (none)"
    (nameFromNone == "Unknown")
    (if nameFromNone == "Unknown" then none else some s!"Expected 'Unknown', got '{nameFromNone}'")

def runAllTests : IO TestRunner := do
  let lensRunner ← runLensTests
  let prismRunner ← runPrismTests
  let traversalRunner ← runTraversalTests
  let compositionRunner ← runCompositionTests
  let integrationRunner ← runIntegrationTests
  return {
    results := lensRunner.results ++ prismRunner.results ++ traversalRunner.results
      ++ compositionRunner.results ++ integrationRunner.results
    total := lensRunner.total + prismRunner.total + traversalRunner.total
      + compositionRunner.total + integrationRunner.total
    passed := lensRunner.passed + prismRunner.passed + traversalRunner.passed
      + compositionRunner.passed + integrationRunner.passed
  }
