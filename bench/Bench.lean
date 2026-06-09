/-
# Performance Benchmarks
-/

import Optics
import Optics.Experimental
import tests.Common

namespace Optics.Bench

open Optics Tests.Common

def companyStreetLens : Lens Company String :=
  (Company.addressLens : Lens Company Address) ∘ₗ (streetLens : Lens Address String)

def benchmarkLensOperations (n : Nat) : IO Unit := do
  let person := testPerson
  let start ← IO.monoMsNow
  for _ in [0:n] do
    let _ := (nameLens : Lens Person String).get person
    let _ := (nameLens : Lens Person String).set person "Bob"
    let _ := (nameLens : Lens Person String).over (fun s => s.toUpper) person
  let stop ← IO.monoMsNow
  IO.println s!"Lens operations ({n} iterations): {stop - start}ms"

def benchmarkPrismOperations (n : Nat) : IO Unit := do
  let maybePerson := some testPerson
  let start ← IO.monoMsNow
  for _ in [0:n] do
    let _ := optionPrism.preview maybePerson
    let _ := optionPrism.build testPerson
  let stop ← IO.monoMsNow
  IO.println s!"Prism operations ({n} iterations): {stop - start}ms"

def benchmarkTraversalOperations (n : Nat) : IO Unit := do
  let people := [testPerson, { testPerson with name := "Bob", age := 25 }]
  let start ← IO.monoMsNow
  for _ in [0:n] do
    let _ := Id.run do listTraversal.traverse (fun p => pure { p with age := p.age + 1 }) people
    let _ := listTraversal.traverse (fun p => some p) people
  let stop ← IO.monoMsNow
  IO.println s!"Traversal operations ({n} iterations): {stop - start}ms"

def benchmarkComposition (n : Nat) : IO Unit := do
  let start ← IO.monoMsNow
  for _ in [0:n] do
    let _ := companyStreetLens.get testCompany
    let _ := companyStreetLens.set testCompany "456 Oak Ave"
  let stop ← IO.monoMsNow
  IO.println s!"Composition operations ({n} iterations): {stop - start}ms"

def run : IO Unit := do
  IO.println "Running lean-optics benchmarks..."
  IO.println ""
  benchmarkLensOperations 1000
  benchmarkPrismOperations 1000
  benchmarkTraversalOperations 1000
  benchmarkComposition 1000
  IO.println ""
  IO.println "Benchmarks completed!"

end Optics.Bench

def main : IO Unit := Optics.Bench.run
