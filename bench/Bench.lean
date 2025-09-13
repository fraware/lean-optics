/-!
# Performance Benchmarks

This module provides performance benchmarks for the lean-optics library.
-/

import Optics
import Lean

namespace Optics.Bench

-- Test data structures
structure Person where
  name : String
  age : Nat
  email : String

structure Address where
  street : String
  city : String
  zip : String

structure Company where
  name : String
  address : Address
  employees : List Person

-- Test lenses
def nameLens : Lens Person String :=
  lens! Person.name (fun p n => { p with name := n })

def ageLens : Lens Person Nat :=
  lens! Person.age (fun p a => { p with age := a })

def addressLens : Lens Company Address :=
  lens! Company.address (fun c a => { c with address := a })

def streetLens : Lens Address String :=
  lens! Address.street (fun a s => { a with street := s })

def employeesLens : Lens Company (List Person) :=
  lens! Company.employees (fun c e => { c with employees := e })

-- Test prisms
def maybePrism {A : Type} : Prism (Option A) A :=
  prism! (fun x => match x with | some a => Sum.inl a | none => Sum.inr none) some

-- Test traversals
def listTraversal {A : Type} : Traversal (List A) A :=
  traversal! (fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listTraversal.traverse f xs
      pure (y :: ys))

-- Benchmark functions
def benchmarkLensOperations (n : Nat) : IO Unit := do
  let person := { name := "Alice", age := 30, email := "alice@example.com" }
  let start := ← IO.monoMsNow
  for _ in [0:n] do
    let _ := nameLens.get person
    let _ := nameLens.set person "Bob"
    let _ := nameLens.over person (fun n => n.toUpper)
  let end := ← IO.monoMsNow
  IO.println s!"Lens operations ({n} iterations): {end - start}ms"

def benchmarkPrismOperations (n : Nat) : IO Unit := do
  let maybePerson := some { name := "Alice", age := 30, email := "alice@example.com" }
  let start := ← IO.monoMsNow
  for _ in [0:n] do
    let _ := maybePrism.preview maybePerson
    let _ := maybePrism.build { name := "Bob", age := 25, email := "bob@example.com" }
  let end := ← IO.monoMsNow
  IO.println s!"Prism operations ({n} iterations): {end - start}ms"

def benchmarkTraversalOperations (n : Nat) : IO Unit := do
  let people := [{ name := "Alice", age := 30, email := "alice@example.com" },
                 { name := "Bob", age := 25, email := "bob@example.com" },
                 { name := "Charlie", age := 35, email := "charlie@example.com" }]
  let start := ← IO.monoMsNow
  for _ in [0:n] do
    let _ := listTraversal.traverse (fun p => p.age + 1) people
    let _ := listTraversal.traverse (fun p => some p) people
  let end := ← IO.monoMsNow
  IO.println s!"Traversal operations ({n} iterations): {end - start}ms"

def benchmarkComposition (n : Nat) : IO Unit := do
  let company := { name := "Acme Corp",
                   address := { street := "123 Main St", city := "Anytown", zip := "12345" },
                   employees := [{ name := "Alice", age := 30, email := "alice@example.com" },
                                { name := "Bob", age := 25, email := "bob@example.com" }] }
  let streetLens' := streetLens ∘ₗ addressLens
  let start := ← IO.monoMsNow
  for _ in [0:n] do
    let _ := streetLens'.get company
    let _ := streetLens'.set company "456 Oak Ave"
  let end := ← IO.monoMsNow
  IO.println s!"Composition operations ({n} iterations): {end - start}ms"

def main : IO Unit := do
  IO.println "Running lean-optics benchmarks..."
  IO.println ""

  benchmarkLensOperations 1000
  benchmarkPrismOperations 1000
  benchmarkTraversalOperations 1000
  benchmarkComposition 1000

  IO.println ""
  IO.println "Benchmarks completed!"

end Optics.Bench
