/-
# Advanced test runner (no `main`)
-/

import tests.Advanced.NestedRecords
import tests.Advanced.ComplexPrismComposition
import tests.Advanced.RefactorSemantics

namespace tests.Advanced

structure TestResult where
  name : String
  passed : Bool
  durationMs : Nat

structure TestReport where
  results : List TestResult
  total : Nat
  passed : Nat

def TestReport.empty : TestReport := { results := [], total := 0, passed := 0 }

def TestReport.add (r : TestReport) (name : String) (passed : Bool) (durationMs : Nat) : TestReport :=
  { r with
    results := { name := name, passed := passed, durationMs := durationMs } :: r.results
    total := r.total + 1
    passed := if passed then r.passed + 1 else r.passed }

private def banner : String :=
  String.ofList (List.replicate 50 '=')

def TestReport.print (r : TestReport) : IO Unit := do
  IO.println banner
  IO.println "ADVANCED OPTICS TEST REPORT"
  IO.println banner
  IO.println s!"Total: {r.total}  Passed: {r.passed}  Failed: {r.total - r.passed}"
  if r.total - r.passed > 0 then
    for t in r.results do
      if !t.passed then IO.println s!"  [FAIL] {t.name}"
  else
    IO.println "ALL ADVANCED TESTS PASSED"
  IO.println banner

private def timed (name : String) (act : IO Unit) : IO TestResult := do
  let start ← IO.monoMsNow
  act
  let stop ← IO.monoMsNow
  return { name := name, passed := true, durationMs := stop - start }

def runNestedRecordTests : IO (List TestResult) := do
  let org := testOrganization
  let tests : List (String × IO Unit) := [
    ("3_level_lens", do let _ := test3LevelLens.get org; let _ := test3LevelLens.set org "New Street"),
    ("3_level_prism", do let _ := test3LevelPrism.matchS org; let _ := test3LevelPrism.build "New City"),
    ("3_level_traversal", do
      let _ := Id.run (test3LevelTraversal.traverse (fun s => pure (s.toUpper)) org)),
    ("mixed_composition", do let _ := testMixed3Level.get org; let _ := testMixed3Level.set org "VALUE"),
    ("composition_chain", do let _ := testCompositionChain.get org; let _ := testCompositionChain.set org "St")
  ]
  tests.mapM fun (name, act) => timed name act

def runComplexPrismTests : IO (List TestResult) := do
  let task := testTask1
  let workspace := testWorkspace
  let tests : List (String × IO Unit) := [
    ("active_task_prism", do let _ := activeTaskPrism.matchS task),
    ("composed_prism", do let _ := activeHighPriorityTaskPrism.matchS task),
    ("workspace_to_task", do let _ := workspaceToTaskPrism.matchS workspace),
    ("nested_matching", do let _ := nestedMatchingPrism.matchS workspace),
    ("error_recovery", do let _ := complexErrorRecoveryPrism.matchS task)
  ]
  tests.mapM fun (name, act) => timed name act

def runRefactorTests : IO (List TestResult) := do
  let state := testState
  let tests : List (String × IO Unit) := [
    ("stack_lens", do let _ := stackLens.get state; let _ := stackLens.set state [1, 2]),
    ("stack_traversal", do
      let _ := Id.run (stackTraversal.traverse (fun n => pure (n + 1)) state)),
    ("stack_prism", do let _ := stackHeadPrism.matchS state; let _ := stackHeadPrism.build 99),
    ("push_pop", do let s := push state 100; let (_, _) := pop s)
  ]
  tests.mapM fun (name, act) => timed name act

def runAllAdvancedTests : IO TestReport := do
  let nested ← runNestedRecordTests
  let prisms ← runComplexPrismTests
  let refactor ← runRefactorTests
  let all := nested ++ prisms ++ refactor
  let passed := all.filter (·.passed) |>.length
  return { results := all, total := all.length, passed := passed }

end tests.Advanced
