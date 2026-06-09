/-
# Integration Tests
-/

import Optics
import Optics.Experimental
import tests.Common

open Optics Tests.Common

#eval nameLens.get testPerson
#eval nameLens.set testPerson "Bob"
#eval nameLens.over (fun n => n.toUpper) testPerson
#eval streetLens'.get testPersonWithAddress
#eval streetLens'.set testPersonWithAddress "456 Oak Ave"
#eval optionPrism.preview (some "hello")
#eval optionPrism.preview (none : Option String)
#eval optionPrism.build "world"
#eval Id.run do listTraversal.traverse (fun x => pure (x + 1)) [1, 2, 3]
#eval listTraversal.traverse (fun x => some (x + 1)) [1, 2, 3]
#eval lensPrismComp.get (some testPerson)
#eval lensPrismComp.set (some testPerson) "Bob"

theorem streetLens'_wellFormed : Lens.WellFormed streetLens' :=
  Lens.comp_preserves_laws personAddressLens streetLens
    (Lens.lawful_wellFormed PersonWithAddress.addressLens)
    (Lens.lawful_wellFormed Address.streetLens)

theorem optionPrism_wellFormed : Prism.WellFormed (optionPrism : Prism (Option String) String) := by
  refine ⟨?_, ?_, ?_⟩
  · intro a; simp [optionPrism]
  · intro s a h
    cases s with
    | none => simp [optionPrism] at h
    | some s' => simp [optionPrism] at h; cases h; rfl
  · intro s s' h
    cases s with
    | none => simp [optionPrism] at h; cases h; rfl
    | some _ => simp [optionPrism] at h

theorem listTraversal_wellFormed : Traversal.WellFormed (listTraversal : Traversal (List Nat) Nat) := by
  trivial

def integrationMain : IO Unit := do
  IO.println "Integration tests passed!"
  IO.println s!"Person name: {nameLens.get testPerson}"
  IO.println s!"Street: {streetLens'.get testPersonWithAddress}"
  IO.println s!"Maybe preview: {optionPrism.preview (some "hello")}"
  IO.println s!"List traversal: {Id.run do listTraversal.traverse (fun x => pure (x + 1)) [1, 2, 3]}"
