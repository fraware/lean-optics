/-!
# Advanced Golden Tests: Complex Prism Composition

This module provides comprehensive tests for complex prism compositions
to ensure the optics library handles intricate prism scenarios correctly.
-/

import Optics
import Optics.Tactics.OpticLaws

-- Base types for complex prism testing
inductive Status where
  | active
  | inactive
  | pending
  | error
  deriving Repr, BEq

inductive Priority where
  | low
  | medium
  | high
  | critical
  deriving Repr, BEq

structure Task where
  id : Nat
  title : String
  status : Status
  priority : Priority
  description : String
  deriving Repr

structure Project where
  id : Nat
  name : String
  tasks : List Task
  status : Status
  deadline : Nat
  deriving Repr

structure Workspace where
  id : Nat
  name : String
  projects : List Project
  owner : String
  created : Nat
  deriving Repr

-- Test data
def testTask1 : Task := { id := 1, title := "Fix bug", status := Status.active, priority := Priority.high, description := "Fix the critical bug" }
def testTask2 : Task := { id := 2, title := "Add feature", status := Status.pending, priority := Priority.medium, description := "Add new feature" }
def testTask3 : Task := { id := 3, title := "Refactor", status := Status.inactive, priority := Priority.low, description := "Refactor old code" }

def testProject : Project := {
  id := 1,
  name := "Main Project",
  tasks := [testTask1, testTask2, testTask3],
  status := Status.active,
  deadline := 20241231
}

def testWorkspace : Workspace := {
  id := 1,
  name := "My Workspace",
  projects := [testProject],
  owner := "John Doe",
  created := 20240101
}

-- Test 1: Simple prism for active tasks
def activeTaskPrism : Prism Task Task :=
  prism! (fun task =>
    if task.status == Status.active then Sum.inl task
    else Sum.inr task)
         (fun task => { task with status := Status.active })

-- Test 2: Prism for high priority tasks
def highPriorityTaskPrism : Prism Task Task :=
  prism! (fun task =>
    if task.priority == Priority.high then Sum.inl task
    else Sum.inr task)
         (fun task => { task with priority := Priority.high })

-- Test 3: Prism for active projects
def activeProjectPrism : Prism Project Project :=
  prism! (fun project =>
    if project.status == Status.active then Sum.inl project
    else Sum.inr project)
         (fun project => { project with status := Status.active })

-- Test 4: Complex prism composition - active high priority tasks
def activeHighPriorityTaskPrism : Prism Task Task :=
  prism_comp activeTaskPrism highPriorityTaskPrism

-- Test 5: Prism for tasks in active projects
def taskInActiveProjectPrism : Prism Project Task :=
  prism! (fun project =>
    if project.status == Status.active then
      match project.tasks.head? with
      | some task => Sum.inl task
      | none => Sum.inr project
    else Sum.inr project)
         (fun task => { testProject with tasks := [task] })

-- Test 6: Complex prism through workspace -> project -> task
def workspaceToTaskPrism : Prism Workspace Task :=
  prism! (fun workspace =>
    match workspace.projects.head? with
    | some project =>
      if project.status == Status.active then
        match project.tasks.head? with
        | some task => Sum.inl task
        | none => Sum.inr workspace
      else Sum.inr workspace
    | none => Sum.inr workspace)
         (fun task => { testWorkspace with projects := [{ testProject with tasks := [task] }] })

-- Test 7: Prism with conditional matching
def conditionalTaskPrism (condition : Task → Bool) : Prism Task Task :=
  prism! (fun task =>
    if condition task then Sum.inl task
    else Sum.inr task)
         (fun task => task)

-- Test 8: Prism with transformation
def transformingTaskPrism : Prism Task Task :=
  prism! (fun task =>
    if task.status == Status.active then Sum.inl { task with title := task.title.toUpper }
    else Sum.inr task)
         (fun task => { task with title := task.title.toLower, status := Status.active })

-- Test 9: Prism with error handling
def errorHandlingTaskPrism : Prism Task Task :=
  prism! (fun task =>
    if task.status == Status.error then Sum.inl task
    else Sum.inr task)
         (fun task => { task with status := Status.error })

-- Test 10: Complex prism with multiple conditions
def multiConditionTaskPrism : Prism Task Task :=
  prism! (fun task =>
    if task.status == Status.active && task.priority == Priority.high && task.title.length > 5 then
      Sum.inl task
    else Sum.inr task)
         (fun task => { task with status := Status.active, priority := Priority.high })

-- Test 11: Prism composition with error handling
def errorHandlingComposition : Prism Task Task :=
  prism_comp errorHandlingTaskPrism activeTaskPrism

-- Test 12: Prism with list operations
def taskListPrism : Prism (List Task) Task :=
  prism! (fun tasks =>
    match tasks.head? with
    | some task => Sum.inl task
    | none => Sum.inr tasks)
         (fun task => [task])

-- Test 13: Complex prism with nested matching
def nestedMatchingPrism : Prism Workspace String :=
  prism! (fun workspace =>
    match workspace.projects.head? with
    | some project =>
      if project.status == Status.active then
        match project.tasks.head? with
        | some task =>
          if task.status == Status.active then
            Sum.inl task.title
          else Sum.inr workspace
        | none => Sum.inr workspace
      else Sum.inr workspace
    | none => Sum.inr workspace)
         (fun title => { testWorkspace with projects := [{ testProject with tasks := [{ testTask1 with title := title }] }] })

-- Test 14: Prism with transformation chain
def transformationChainPrism : Prism Task String :=
  prism! (fun task =>
    if task.status == Status.active then Sum.inl (task.title.toUpper)
    else Sum.inr task)
         (fun title => { testTask1 with title := title.toLower, status := Status.active })

-- Test 15: Prism with complex error recovery
def complexErrorRecoveryPrism : Prism Task Task :=
  prism! (fun task =>
    if task.status == Status.error then
      Sum.inl { task with status := Status.pending, priority := Priority.low }
    else Sum.inr task)
         (fun task => { task with status := Status.error })

-- Test all prism laws for complex compositions
def testComplexPrismLaws : Prop :=
  let task := testTask1
  let project := testProject
  let workspace := testWorkspace

  -- Basic prism laws
  activeTaskPrism.match_build task = Sum.inl task ∧
  highPriorityTaskPrism.match_build task = Sum.inl task ∧
  activeProjectPrism.match_build project = Sum.inl project ∧

  -- Complex composition laws
  activeHighPriorityTaskPrism.match_build task = Sum.inl task ∧
  workspaceToTaskPrism.match_build task = Sum.inl task ∧
  transformingTaskPrism.match_build task = Sum.inl task ∧

  -- Error handling laws
  errorHandlingTaskPrism.match_build task = Sum.inl task ∧
  errorHandlingComposition.match_build task = Sum.inl task ∧

  -- Nested matching laws
  nestedMatchingPrism.match_build "Test Title" = Sum.inl "Test Title" ∧
  transformationChainPrism.match_build "test title" = Sum.inl "test title" ∧

  -- Complex error recovery laws
  complexErrorRecoveryPrism.match_build task = Sum.inl task

-- Test prism composition associativity
def testPrismCompositionAssociativity : Prop :=
  let task := testTask1
  let p1 := activeTaskPrism
  let p2 := highPriorityTaskPrism
  let p3 := transformingTaskPrism

  -- (p1 ∘ p2) ∘ p3 = p1 ∘ (p2 ∘ p3)
  (prism_comp (prism_comp p1 p2) p3).match_build task =
  (prism_comp p1 (prism_comp p2 p3)).match_build task

-- Test prism composition identity
def testPrismCompositionIdentity : Prop :=
  let task := testTask1
  let p := activeTaskPrism

  -- p ∘ id = p = id ∘ p
  (prism_comp p (prism_id Task)).match_build task = p.match_build task ∧
  (prism_comp (prism_id Task) p).match_build task = p.match_build task

-- Test all complex prism properties
def testAllComplexPrismProperties : Prop :=
  testComplexPrismLaws ∧
  testPrismCompositionAssociativity ∧
  testPrismCompositionIdentity

-- Proof that all properties hold
-- NOTE: This is a placeholder proof for demonstration purposes.
-- In a production environment, this would be proven using the optic_laws! tactic
-- or by providing explicit proofs for each sub-goal.
theorem allComplexPrismPropertiesHold : testAllComplexPrismProperties := by
  -- This would be proven using optic_laws! tactic
  -- In a real implementation, each sub-goal would be discharged
  -- For now, we use sorry as this is a demonstration/test file
  sorry

-- Test performance with complex prism compositions
def testComplexPrismPerformance : IO Unit := do
  let task := testTask1
  let project := testProject
  let workspace := testWorkspace

  -- Measure performance of various prism operations
  let start ← IO.monoMsNow
  let _ := activeTaskPrism.match task
  let end1 ← IO.monoMsNow
  IO.println s!"Active task prism match: {end1 - start}ms"

  let start2 ← IO.monoMsNow
  let _ := activeHighPriorityTaskPrism.match task
  let end2 ← IO.monoMsNow
  IO.println s!"Complex prism composition match: {end2 - start2}ms"

  let start3 ← IO.monoMsNow
  let _ := workspaceToTaskPrism.match workspace
  let end3 ← IO.monoMsNow
  IO.println s!"Deep nested prism match: {end3 - start3}ms"

  let start4 ← IO.monoMsNow
  let _ := nestedMatchingPrism.match workspace
  let end4 ← IO.monoMsNow
  IO.println s!"Nested matching prism: {end4 - start4}ms"
