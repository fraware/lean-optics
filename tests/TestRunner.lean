/-!
# Test Runner for Lean Optics

This module provides a comprehensive test runner that executes all test modules
and reports the results.
-/

import Optics
import Tests.Lens.Basic
import Tests.Prism.Basic
import Tests.Traversal.Basic
import Tests.Compose.Basic
import Tests.Integration

-- Test result tracking
structure TestResult where
  name : String
  passed : Bool
  error : Option String

-- Test runner state
structure TestRunner where
  results : List TestResult
  total : Nat
  passed : Nat

def TestRunner.empty : TestRunner :=
  { results := [], total := 0, passed := 0 }

def TestRunner.addResult (tr : TestRunner) (name : String) (passed : Bool) (error : Option String := none) : TestRunner :=
  { tr with
    results := { name := name, passed := passed, error := error } :: tr.results
    total := tr.total + 1
    passed := if passed then tr.passed + 1 else tr.passed }

def TestRunner.report (tr : TestRunner) : IO Unit := do
  IO.println "=" * 50
  IO.println "LEAN OPTICS TEST SUITE REPORT"
  IO.println "=" * 50
  IO.println s!"Total Tests: {tr.total}"
  IO.println s!"Passed: {tr.passed}"
  IO.println s!"Failed: {tr.total - tr.passed}"
  IO.println s!"Success Rate: {if tr.total > 0 then (tr.passed * 100 / tr.total) else 0}%"
  IO.println ""

  if tr.total - tr.passed > 0 then
    IO.println "FAILED TESTS:"
    for result in tr.results do
      if !result.passed then
        IO.println s!"  ❌ {result.name}"
        if let some err := result.error then
          IO.println s!"     Error: {err}"
  else
    IO.println "✅ ALL TESTS PASSED!"

  IO.println "=" * 50

-- Test execution functions
def runLensTests : IO TestRunner := do
  let mut runner := TestRunner.empty

  -- Test basic lens operations
  try
    let testPerson : Person := { name := "Alice", age := 30, email := "alice@example.com" }
    let nameLens : Lens Person String := lens! Person.name (fun p n => { p with name := n })

    -- Test get operation
    let name := nameLens.get testPerson
    if name != "Alice" then
      runner := runner.addResult "Lens.get" false (some "Expected 'Alice', got '{name}'")
    else
      runner := runner.addResult "Lens.get" true

    -- Test set operation
    let updatedPerson := nameLens.set testPerson "Bob"
    if updatedPerson.name != "Bob" then
      runner := runner.addResult "Lens.set" false (some "Expected 'Bob', got '{updatedPerson.name}'")
    else
      runner := runner.addResult "Lens.set" true

    -- Test over operation
    let upperPerson := nameLens.over testPerson (fun n => n.toUpper)
    if upperPerson.name != "ALICE" then
      runner := runner.addResult "Lens.over" false (some "Expected 'ALICE', got '{upperPerson.name}'")
    else
      runner := runner.addResult "Lens.over" true

  catch e =>
    runner := runner.addResult "Lens Basic Tests" false (some s!"Exception: {e}")

  return runner

def runPrismTests : IO TestRunner := do
  let mut runner := TestRunner.empty

  try
    let maybePrism : Prism (Option String) String :=
      prism! (fun x => match x with | some s => Sum.inl s | none => Sum.inr none) some

    -- Test preview operation
    let previewSome := maybePrism.preview (some "test")
    if previewSome != some "test" then
      runner := runner.addResult "Prism.preview (some)" false (some "Expected some 'test', got '{previewSome}'")
    else
      runner := runner.addResult "Prism.preview (some)" true

    let previewNone := maybePrism.preview none
    if previewNone != none then
      runner := runner.addResult "Prism.preview (none)" false (some "Expected none, got '{previewNone}'")
    else
      runner := runner.addResult "Prism.preview (none)" true

    -- Test build operation
    let built := maybePrism.build "test"
    if built != some "test" then
      runner := runner.addResult "Prism.build" false (some "Expected some 'test', got '{built}'")
    else
      runner := runner.addResult "Prism.build" true

  catch e =>
    runner := runner.addResult "Prism Basic Tests" false (some s!"Exception: {e}")

  return runner

def runTraversalTests : IO TestRunner := do
  let mut runner := TestRunner.empty

  try
    let listTraversal : Traversal (List Nat) Nat :=
      traversal! (fun {F} [Applicative F] f xs =>
        match xs with
        | [] => pure []
        | x :: xs => do
          let y ← f x
          let ys ← listTraversal.traverse f xs
          pure (y :: ys))

    -- Test traverse operation
    let result := listTraversal.traverse (fun x => x + 1) [1, 2, 3]
    if result != [2, 3, 4] then
      runner := runner.addResult "Traversal.traverse" false (some "Expected [2, 3, 4], got '{result}'")
    else
      runner := runner.addResult "Traversal.traverse" true

  catch e =>
    runner := runner.addResult "Traversal Basic Tests" false (some s!"Exception: {e}")

  return runner

def runCompositionTests : IO TestRunner := do
  let mut runner := TestRunner.empty

  try
    -- Test lens composition
    let streetLens : Lens Address String := lens! Address.street (fun a s => { a with street := s })
    let addressLens : Lens Person Address := lens! Person.address (fun p a => { p with address := a })
    let streetLens' : Lens Person String := streetLens ∘ₗ addressLens

    let testPerson : Person :=
      { name := "Alice", age := 30, address := { street := "Main St", city := "Anytown", zip := "12345" } }

    let street := streetLens'.get testPerson
    if street != "Main St" then
      runner := runner.addResult "Lens Composition" false (some "Expected 'Main St', got '{street}'")
    else
      runner := runner.addResult "Lens Composition" true

  catch e =>
    runner := runner.addResult "Composition Tests" false (some s!"Exception: {e}")

  return runner

def runIntegrationTests : IO TestRunner := do
  let mut runner := TestRunner.empty

  try
    -- Test mixed composition
    let maybePrism : Prism (Option Person) Person :=
      prism! (fun x => match x with | some p => Sum.inl p | none => Sum.inr none) some

    let nameLens : Lens Person String := lens! Person.name (fun p n => { p with name := n })
    let lensPrismComp : Lens (Option Person) String :=
      lens_prism_comp nameLens maybePrism "Unknown"

    let testPerson : Person := { name := "Alice", age := 30, email := "alice@example.com" }
    let somePerson := some testPerson
    let nonePerson : Option Person := none

    let nameFromSome := lensPrismComp.get somePerson
    if nameFromSome != "Alice" then
      runner := runner.addResult "Integration: Lens-Prism Composition (some)" false (some "Expected 'Alice', got '{nameFromSome}'")
    else
      runner := runner.addResult "Integration: Lens-Prism Composition (some)" true

    let nameFromNone := lensPrismComp.get nonePerson
    if nameFromNone != "Unknown" then
      runner := runner.addResult "Integration: Lens-Prism Composition (none)" false (some "Expected 'Unknown', got '{nameFromNone}'")
    else
      runner := runner.addResult "Integration: Lens-Prism Composition (none)" true

  catch e =>
    runner := runner.addResult "Integration Tests" false (some s!"Exception: {e}")

  return runner

-- Main test execution
def main : IO Unit := do
  IO.println "Starting Lean Optics Test Suite..."
  IO.println ""

  let mut totalRunner := TestRunner.empty

  -- Run all test suites
  let lensRunner ← runLensTests
  let prismRunner ← runPrismTests
  let traversalRunner ← runTraversalTests
  let compositionRunner ← runCompositionTests
  let integrationRunner ← runIntegrationTests

  -- Combine results
  totalRunner := {
    results := lensRunner.results ++ prismRunner.results ++ traversalRunner.results ++ compositionRunner.results ++ integrationRunner.results
    total := lensRunner.total + prismRunner.total + traversalRunner.total + compositionRunner.total + integrationRunner.total
    passed := lensRunner.passed + prismRunner.passed + traversalRunner.passed + compositionRunner.passed + integrationRunner.passed
  }

  -- Report results
  totalRunner.report

  -- Exit with appropriate code
  if totalRunner.passed == totalRunner.total then
    IO.println "All tests passed! 🎉"
    System.Exit.exit 0
  else
    IO.println "Some tests failed! ❌"
    System.Exit.exit 1
