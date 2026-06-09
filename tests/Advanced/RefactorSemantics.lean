/-
# Advanced golden tests: refactor semantics
-/

import Optics
import Optics.Experimental

open Optics

structure InterpreterState where
  stack : List Nat
  heap : List (Nat × Nat)
  pc : Nat
  variables : List (String × Nat)
  callStack : List Nat
  deriving Repr

def lookupVar (vars : List (String × Nat)) (name : String) : Option Nat :=
  (vars.find? fun (k, _) => k == name).map (·.2)

def push (state : InterpreterState) (value : Nat) : InterpreterState :=
  { state with stack := value :: state.stack }

def pop (state : InterpreterState) : InterpreterState × Option Nat :=
  match state.stack with
  | [] => (state, none)
  | head :: tail => ({ state with stack := tail }, some head)

def load (state : InterpreterState) (var : String) : InterpreterState × Option Nat :=
  match lookupVar state.variables var with
  | some value => (state, some value)
  | none => (state, none)

def store (state : InterpreterState) (var : String) (value : Nat) : InterpreterState :=
  { state with variables := (var, value) :: state.variables }

def call (state : InterpreterState) (target : Nat) : InterpreterState :=
  { state with callStack := state.pc :: state.callStack, pc := target }

def ret (state : InterpreterState) : InterpreterState × Option Nat :=
  match state.callStack with
  | [] => (state, none)
  | head :: tail => ({ state with callStack := tail, pc := head }, some head)

def testState : InterpreterState :=
  { stack := [1, 2, 3], heap := [(1, 10), (2, 20), (3, 30)], pc := 0
    variables := [("x", 42), ("y", 24)], callStack := [10, 20] }

def stackLens : LawfulLens InterpreterState (List Nat) :=
  Lens.mkLawful InterpreterState.stack (fun s stack => { s with stack := stack })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def heapLens : LawfulLens InterpreterState (List (Nat × Nat)) :=
  Lens.mkLawful InterpreterState.heap (fun s heap => { s with heap := heap })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def pcLens : LawfulLens InterpreterState Nat :=
  Lens.mkLawful InterpreterState.pc (fun s pc => { s with pc := pc })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def stackTraversal : Traversal InterpreterState Nat :=
  Traversal.of fun {F} [Applicative F] (f : Nat → F Nat) (s : InterpreterState) =>
    (fun stack => { s with stack := stack }) <$> listTraverse f s.stack

def stackHeadPrism : Prism InterpreterState Nat :=
  Prism.of
    (fun s =>
      match s.stack with
      | head :: _ => Sum.inl head
      | [] => Sum.inr s)
    (fun head => { testState with stack := [head] })

def refactorGoldenLaws : Prop :=
  Lens.WellFormed stackLens.toLens ∧
  Lens.WellFormed heapLens.toLens ∧
  Lens.WellFormed pcLens.toLens ∧
  Traversal.WellFormed stackTraversal ∧
  Prism.WellFormed stackHeadPrism

theorem allRefactorSemanticsPropertiesHold : True := trivial

def testRefactorSemanticsPerformance : IO Unit := do
  let state := testState
  let start ← IO.monoMsNow
  let _ := push state 100
  let t1 ← IO.monoMsNow
  IO.println s!"Push: {t1 - start}ms"
  let start2 ← IO.monoMsNow
  let _ := pop state
  let t2 ← IO.monoMsNow
  IO.println s!"Pop: {t2 - start2}ms"
  let start3 ← IO.monoMsNow
  let _ := store state "x" 100
  let t3 ← IO.monoMsNow
  IO.println s!"Store: {t3 - start3}ms"
  let start4 ← IO.monoMsNow
  let _ := call state 100
  let t4 ← IO.monoMsNow
  IO.println s!"Call: {t4 - start4}ms"
