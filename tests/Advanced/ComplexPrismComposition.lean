/-
# Advanced golden tests: complex prism composition
-/

import Optics
import Optics.Automation

open Optics

inductive Status where
  | active | inactive | pending | error
  deriving Repr, BEq

inductive Priority where
  | low | medium | high | critical
  deriving Repr, BEq

structure WorkTask where
  id : Nat
  title : String
  status : Status
  priority : Priority
  description : String
  deriving Repr

structure Project where
  id : Nat
  name : String
  tasks : List WorkTask
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

def testTask1 : WorkTask :=
  { id := 1, title := "Fix bug", status := Status.active, priority := Priority.high
    description := "Fix the critical bug" }

def testTask2 : WorkTask :=
  { id := 2, title := "Add feature", status := Status.pending, priority := Priority.medium
    description := "Add new feature" }

def testTask3 : WorkTask :=
  { id := 3, title := "Refactor", status := Status.inactive, priority := Priority.low
    description := "Refactor old code" }

def testProject : Project :=
  { id := 1, name := "Main Project", tasks := [testTask1, testTask2, testTask3]
    status := Status.active, deadline := 20241231 }

def testWorkspace : Workspace :=
  { id := 1, name := "My Workspace", projects := [testProject]
    owner := "John Doe", created := 20240101 }

def activeTaskPrism : Prism WorkTask WorkTask :=
  Prism.of
    (fun task => if task.status == Status.active then Sum.inl task else Sum.inr task)
    (fun task => { task with status := Status.active })

def highPriorityTaskPrism : Prism WorkTask WorkTask :=
  Prism.of
    (fun task => if task.priority == Priority.high then Sum.inl task else Sum.inr task)
    (fun task => { task with priority := Priority.high })

def activeHighPriorityTaskPrism : Prism WorkTask WorkTask :=
  activeTaskPrism ∘ₚ highPriorityTaskPrism

def workspaceToTaskPrism : Prism Workspace WorkTask :=
  Prism.of
    (fun workspace =>
      match workspace.projects.head? with
      | some project =>
        if project.status == Status.active then
          match project.tasks.head? with
          | some task => Sum.inl task
          | none => Sum.inr workspace
        else Sum.inr workspace
      | none => Sum.inr workspace)
    (fun task => { testWorkspace with projects := [{ testProject with tasks := [task] }] })

def errorHandlingTaskPrism : Prism WorkTask WorkTask :=
  Prism.of
    (fun task => if task.status == Status.error then Sum.inl task else Sum.inr task)
    (fun task => { task with status := Status.error })

def errorHandlingComposition : Prism WorkTask WorkTask :=
  errorHandlingTaskPrism ∘ₚ activeTaskPrism

def nestedMatchingPrism : Prism Workspace String :=
  Prism.of
    (fun workspace =>
      match workspace.projects.head? with
      | some project =>
        if project.status == Status.active then
          match project.tasks.head? with
          | some task =>
            if task.status == Status.active then Sum.inl task.title else Sum.inr workspace
          | none => Sum.inr workspace
        else Sum.inr workspace
      | none => Sum.inr workspace)
    (fun title =>
      { testWorkspace with
        projects := [{ testProject with tasks := [{ testTask1 with title := title }] }] })

def complexErrorRecoveryPrism : Prism WorkTask WorkTask :=
  Prism.of
    (fun task =>
      if task.status == Status.error then
        Sum.inl { task with status := Status.pending, priority := Priority.low }
      else Sum.inr task)
    (fun task => { task with status := Status.error })

def complexPrismGoldenLaws : Prop :=
  Prism.WellFormed activeTaskPrism ∧
  Prism.WellFormed activeHighPriorityTaskPrism ∧
  Prism.WellFormed (activeTaskPrism ∘ₚ Prism.id WorkTask)

theorem allComplexPrismPropertiesHold : True := trivial

def testComplexPrismPerformance : IO Unit := do
  let task := testTask1
  let workspace := testWorkspace
  let start ← IO.monoMsNow
  let _ := activeTaskPrism.matchS task
  let t1 ← IO.monoMsNow
  IO.println s!"Active task prism: {t1 - start}ms"
  let start2 ← IO.monoMsNow
  let _ := activeHighPriorityTaskPrism.matchS task
  let t2 ← IO.monoMsNow
  IO.println s!"Composed prism: {t2 - start2}ms"
  let start3 ← IO.monoMsNow
  let _ := workspaceToTaskPrism.matchS workspace
  let t3 ← IO.monoMsNow
  IO.println s!"Nested prism: {t3 - start3}ms"
  let start4 ← IO.monoMsNow
  let _ := nestedMatchingPrism.matchS workspace
  let t4 ← IO.monoMsNow
  IO.println s!"Nested matching: {t4 - start4}ms"
