/-!
# Advanced Test Runner

This module provides a comprehensive test runner for all advanced optics tests,
including performance benchmarks, determinism verification, and complex scenarios.
-/

import Optics
import Optics.Tactics.OpticLaws
import Optics.Telemetry.Core
import Optics.Telemetry.Timing
import Optics.Verification.Determinism
import Optics.Verification.Performance
import Tests.Advanced.NestedRecords
import Tests.Advanced.ComplexPrismComposition
import Tests.Advanced.RefactorSemantics

namespace Optics.Tests.Advanced

/-- Test configuration -/
structure TestConfig where
  enableTelemetry : Bool := false
  enablePerformanceTests : Bool := true
  enableDeterminismTests : Bool := true
  enableComplexTests : Bool := true
  maxTestTime : Nat := 10000 -- milliseconds
  performanceThreshold : Nat := 200 -- milliseconds

/-- Test result -/
structure TestResult where
  testName : String
  success : Bool
  duration : Nat
  errorMessage : Option String := none
  performanceData : Option (Array Nat) := none

/-- Run a single test with timing -/
def runSingleTest (testName : String) (test : IO Unit) : IO TestResult := do
  let startTime ← IO.monoMsNow
  try
    test
    let endTime ← IO.monoMsNow
    let duration := endTime - startTime
    pure { testName, success := true, duration }
  catch e =>
    let endTime ← IO.monoMsNow
    let duration := endTime - startTime
    pure { testName, success := false, duration, errorMessage := some e.toString }

/-- Run nested record tests -/
def runNestedRecordTests : IO (Array TestResult) := do
  let tests : Array (String × IO Unit) := #[
    ("3_level_lens_composition", do
      let org := testOrganization
      let lens := test3LevelLens
      let _ := lens.get org
      let _ := lens.set org "New Street"
      pure ()),
    ("3_level_prism_composition", do
      let org := testOrganization
      let prism := test3LevelPrism
      let _ := prism.match org
      let _ := prism.build "New City"
      pure ()),
    ("3_level_traversal_composition", do
      let org := testOrganization
      let traversal := test3LevelTraversal
      let _ := traversal.traverse (fun s => s.toUpper) org
      pure ()),
    ("mixed_3_level_composition", do
      let org := testOrganization
      let mixed := testMixed3Level
      let _ := mixed.get org
      let _ := mixed.set org "New Value"
      pure ()),
    ("deep_traversal_with_filtering", do
      let org := testOrganization
      let traversal := testDeepTraversal
      let _ := traversal.traverse (fun s => s.toUpper) org
      pure ()),
    ("complex_lens_with_multiple_fields", do
      let org := testOrganization
      let lens := testComplexLens
      let _ := lens.get org
      let _ := lens.set org ("New Name", "New City", 200)
      pure ()),
    ("complex_prism_with_matching", do
      let org := testOrganization
      let prism := testComplexPrism
      let _ := prism.match org
      let _ := prism.build ["Dept1", "Dept2"]
      pure ()),
    ("conditional_traversal", do
      let org := testOrganization
      let traversal := testConditionalTraversal
      let _ := traversal.traverse (fun s => s.toUpper) org
      pure ()),
    ("lens_with_defaults", do
      let org := testOrganization
      let lens := testLensWithDefaults
      let _ := lens.get org
      let _ := lens.set org "New Street"
      pure ()),
    ("composition_chain", do
      let org := testOrganization
      let lens := testCompositionChain
      let _ := lens.get org
      let _ := lens.set org "New Street"
      pure ())
  ]

  let mut results := #[]
  for (name, test) in tests do
    let result ← runSingleTest name test
    results := results.push result
  pure results

/-- Run complex prism composition tests -/
def runComplexPrismTests : IO (Array TestResult) := do
  let tests : Array (String × IO Unit) := #[
    ("active_task_prism", do
      let task := testTask1
      let prism := activeTaskPrism
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("high_priority_task_prism", do
      let task := testTask1
      let prism := highPriorityTaskPrism
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("active_high_priority_composition", do
      let task := testTask1
      let prism := activeHighPriorityTaskPrism
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("task_in_active_project_prism", do
      let project := testProject
      let prism := taskInActiveProjectPrism
      let _ := prism.match project
      let _ := prism.build testTask1
      pure ()),
    ("workspace_to_task_prism", do
      let workspace := testWorkspace
      let prism := workspaceToTaskPrism
      let _ := prism.match workspace
      let _ := prism.build testTask1
      pure ()),
    ("conditional_task_prism", do
      let task := testTask1
      let prism := conditionalTaskPrism (fun t => t.status == Status.active)
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("transforming_task_prism", do
      let task := testTask1
      let prism := transformingTaskPrism
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("error_handling_task_prism", do
      let task := testTask1
      let prism := errorHandlingTaskPrism
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("multi_condition_task_prism", do
      let task := testTask1
      let prism := multiConditionTaskPrism
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("error_handling_composition", do
      let task := testTask1
      let prism := errorHandlingComposition
      let _ := prism.match task
      let _ := prism.build task
      pure ()),
    ("task_list_prism", do
      let tasks := [testTask1, testTask2, testTask3]
      let prism := taskListPrism
      let _ := prism.match tasks
      let _ := prism.build testTask1
      pure ()),
    ("nested_matching_prism", do
      let workspace := testWorkspace
      let prism := nestedMatchingPrism
      let _ := prism.match workspace
      let _ := prism.build "Test Title"
      pure ()),
    ("transformation_chain_prism", do
      let task := testTask1
      let prism := transformationChainPrism
      let _ := prism.match task
      let _ := prism.build "test title"
      pure ()),
    ("complex_error_recovery_prism", do
      let task := testTask1
      let prism := complexErrorRecoveryPrism
      let _ := prism.match task
      let _ := prism.build task
      pure ())
  ]

  let mut results := #[]
  for (name, test) in tests do
    let result ← runSingleTest name test
    results := results.push result
  pure results

/-- Run refactor semantics tests -/
def runRefactorSemanticsTests : IO (Array TestResult) := do
  let tests : Array (String × IO Unit) := #[
    ("stack_operations_preservation", do
      let state := testState
      let (newState1, _) := pop state
      let newState2 := push newState1 100
      let (newState3, _) := pop newState2
      pure ()),
    ("variable_operations_preservation", do
      let state := testState
      let newState1 := store state "z" 100
      let (newState2, _) := load newState1 "z"
      pure ()),
    ("control_flow_preservation", do
      let state := testState
      let newState1 := call state 100
      let (newState2, _) := ret newState1
      pure ()),
    ("heap_operations_preservation", do
      let state := testState
      let newState := { state with heap := (4, 40) :: state.heap }
      pure ()),
    ("complex_state_transformation_preservation", do
      let state := testState
      let newState1 := push state 100
      let newState2 := store newState1 "temp" 200
      let newState3 := call newState2 300
      let (newState4, _) := pop newState3
      let (newState5, _) := ret newState4
      pure ()),
    ("state_equality_preservation", do
      let state1 := testState
      let state2 := testState
      let _ := state1 = state2
      pure ()),
    ("state_inequality_preservation", do
      let state1 := testState
      let state2 := push state1 100
      let _ := state1 ≠ state2
      pure ()),
    ("state_serialization_preservation", do
      let state := testState
      let serialized := state.toString
      let deserialized := state
      let _ := deserialized = state
      pure ()),
    ("state_cloning_preservation", do
      let state := testState
      let cloned := { state with }
      let _ := cloned = state
      pure ()),
    ("state_mutation_preservation", do
      let state := testState
      let mutated := { state with stack := [100, 200, 300] }
      let _ := mutated.stack = [100, 200, 300]
      pure ()),
    ("state_composition_preservation", do
      let state := testState
      let f1 := fun s => push s 100
      let f2 := fun s => store s "x" 200
      let f3 := fun s => call s 300
      let composed := f3 (f2 (f1 state))
      let stepByStep := f1 state |> f2 |> f3
      let _ := composed = stepByStep
      pure ()),
    ("state_monad_laws_preservation", do
      let state := testState
      let f := fun s => push s 100
      let g := fun s => store s "x" 200
      let leftIdentity := push state 100 = f state
      let rightIdentity := state = state
      let associativity := (f state |> g) = (fun s => f s |> g) state
      let _ := leftIdentity && rightIdentity && associativity
      pure ()),
    ("state_optics_preservation", do
      let state := testState
      let stackLens := lens! (fun s => s.stack) (fun s stack => { s with stack := stack })
      let heapLens := lens! (fun s => s.heap) (fun s heap => { s with heap := heap })
      let pcLens := lens! (fun s => s.pc) (fun s pc => { s with pc := pc })
      let _ := stackLens.get state
      let _ := heapLens.get state
      let _ := pcLens.get state
      pure ()),
    ("state_traversal_preservation", do
      let state := testState
      let stackTraversal := traversal! (fun f s => { s with stack := s.stack.map f })
      let heapTraversal := traversal! (fun f s => { s with heap := s.heap.map (fun (k, v) => (k, f v)) })
      let _ := stackTraversal.traverse (fun x => x + 1) state
      let _ := heapTraversal.traverse (fun x => x + 1) state
      pure ()),
    ("state_prism_preservation", do
      let state := testState
      let stackPrism := prism! (fun s =>
        if s.stack.length > 0 then Sum.inl s.stack.head!
        else Sum.inr s)
             (fun head => { state with stack := [head] })
      let _ := stackPrism.match state
      let _ := stackPrism.build 100
      pure ())
  ]

  let mut results := #[]
  for (name, test) in tests do
    let result ← runSingleTest name test
    results := results.push result
  pure results

/-- Run performance benchmarks -/
def runPerformanceBenchmarks : IO (Array TestResult) := do
  let tests : Array (String × IO Unit) := #[
    ("lens_get_performance", do
      let org := testOrganization
      let lens := test3LevelLens
      for _ in [0:1000] do
        let _ := lens.get org
      pure ()),
    ("lens_set_performance", do
      let org := testOrganization
      let lens := test3LevelLens
      for _ in [0:1000] do
        let _ := lens.set org "New Street"
      pure ()),
    ("prism_match_performance", do
      let org := testOrganization
      let prism := test3LevelPrism
      for _ in [0:1000] do
        let _ := prism.match org
      pure ()),
    ("prism_build_performance", do
      let org := testOrganization
      let prism := test3LevelPrism
      for _ in [0:1000] do
        let _ := prism.build "New City"
      pure ()),
    ("traversal_performance", do
      let org := testOrganization
      let traversal := test3LevelTraversal
      for _ in [0:1000] do
        let _ := traversal.traverse (fun s => s.toUpper) org
      pure ()),
    ("complex_composition_performance", do
      let org := testOrganization
      let lens := testCompositionChain
      for _ in [0:1000] do
        let _ := lens.get org
        let _ := lens.set org "New Street"
      pure ()),
    ("mixed_composition_performance", do
      let org := testOrganization
      let lens := testMixed3Level
      for _ in [0:1000] do
        let _ := lens.get org
        let _ := lens.set org "New Value"
      pure ()),
    ("deep_traversal_performance", do
      let org := testOrganization
      let traversal := testDeepTraversal
      for _ in [0:1000] do
        let _ := traversal.traverse (fun s => s.toUpper) org
      pure ()),
    ("conditional_traversal_performance", do
      let org := testOrganization
      let traversal := testConditionalTraversal
      for _ in [0:1000] do
        let _ := traversal.traverse (fun s => s.toUpper) org
      pure ()),
    ("complex_prism_performance", do
      let workspace := testWorkspace
      let prism := nestedMatchingPrism
      for _ in [0:1000] do
        let _ := prism.match workspace
        let _ := prism.build "Test Title"
      pure ())
  ]

  let mut results := #[]
  for (name, test) in tests do
    let result ← runSingleTest name test
    results := results.push result
  pure results

/-- Run all advanced tests -/
def runAllAdvancedTests (config : TestConfig) : IO (Array TestResult) := do
  IO.println "Running advanced optics tests..."

  let mut allResults := #[]

  -- Run nested record tests
  if config.enableComplexTests then
    IO.println "Running nested record tests..."
    let nestedResults ← runNestedRecordTests
    allResults := allResults.append nestedResults

  -- Run complex prism tests
  if config.enableComplexTests then
    IO.println "Running complex prism composition tests..."
    let prismResults ← runComplexPrismTests
    allResults := allResults.append prismResults

  -- Run refactor semantics tests
  if config.enableComplexTests then
    IO.println "Running refactor semantics tests..."
    let refactorResults ← runRefactorSemanticsTests
    allResults := allResults.append refactorResults

  -- Run performance benchmarks
  if config.enablePerformanceTests then
    IO.println "Running performance benchmarks..."
    let performanceResults ← runPerformanceBenchmarks
    allResults := allResults.append performanceResults

  pure allResults

/-- Generate test report -/
def generateTestReport (results : Array TestResult) : IO Unit := do
  let total := results.size
  let successful := results.filter (·.success) |>.size
  let failed := results.filter (¬ ·.success) |>.size
  let avgDuration := results.map (·.duration) |>.foldl (· + ·) 0 / total

  IO.println "=== Advanced Optics Test Report ==="
  IO.println s!"Total tests: {total}"
  IO.println s!"Successful: {successful}"
  IO.println s!"Failed: {failed}"
  IO.println s!"Average duration: {avgDuration}ms"
  IO.println ""

  -- Group results by test type
  let nestedResults := results.filter (·.testName.contains "3_level")
  let prismResults := results.filter (·.testName.contains "prism")
  let refactorResults := results.filter (·.testName.contains "preservation")
  let performanceResults := results.filter (·.testName.contains "performance")

  IO.println "=== Test Categories ==="
  IO.println s!"Nested record tests: {nestedResults.filter (·.success) |>.size}/{nestedResults.size}"
  IO.println s!"Prism composition tests: {prismResults.filter (·.success) |>.size}/{prismResults.size}"
  IO.println s!"Refactor semantics tests: {refactorResults.filter (·.success) |>.size}/{refactorResults.size}"
  IO.println s!"Performance tests: {performanceResults.filter (·.success) |>.size}/{performanceResults.size}"
  IO.println ""

  -- Show failed tests
  let failedTests := results.filter (¬ ·.success)
  if failedTests.size > 0 then
    IO.println "=== Failed Tests ==="
    for result in failedTests do
      IO.println s!"❌ {result.testName}: {result.errorMessage.getD "Unknown error"}"
    IO.println ""

  -- Show performance summary
  let performanceTests := results.filter (·.testName.contains "performance")
  if performanceTests.size > 0 then
    IO.println "=== Performance Summary ==="
    for result in performanceTests do
      let status := if result.duration > 200 then "⚠️ " else "✅ "
      IO.println s!"{status}{result.testName}: {result.duration}ms"
    IO.println ""

/-- Main test runner -/
def main : IO Unit := do
  let config := {
    enableTelemetry := true
    enablePerformanceTests := true
    enableDeterminismTests := true
    enableComplexTests := true
    maxTestTime := 10000
    performanceThreshold := 200
  }

  let results ← runAllAdvancedTests config
  generateTestReport results

  -- Check if all tests passed
  let allPassed := results.all (·.success)
  if allPassed then
    IO.println "🎉 All advanced tests passed!"
  else
    IO.println "❌ Some tests failed. See details above."
    exit 1

end Optics.Tests.Advanced
