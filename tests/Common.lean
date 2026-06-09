/-
# Shared test fixtures

Macro-free lawful optics and sample records reused across the test suite.
-/

import Optics
import Optics.Experimental

namespace Tests.Common

open Optics

structure Address where
  street : String
  city : String
  zip : String
  deriving Repr

structure Person where
  name : String
  age : Nat
  email : String
  deriving Repr

structure PersonWithAddress where
  name : String
  age : Nat
  address : Address
  deriving Repr

structure Company where
  name : String
  address : Address
  employees : List Person
  deriving Repr

def Person.nameLens : LawfulLens Person String :=
  Lens.mkLawful Person.name (fun p n => { p with name := n })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def Person.ageLens : LawfulLens Person Nat :=
  Lens.mkLawful Person.age (fun p a => { p with age := a })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def Person.emailLens : LawfulLens Person String :=
  Lens.mkLawful Person.email (fun p e => { p with email := e })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def Address.streetLens : LawfulLens Address String :=
  Lens.mkLawful Address.street (fun a s => { a with street := s })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def PersonWithAddress.addressLens : LawfulLens PersonWithAddress Address :=
  Lens.mkLawful PersonWithAddress.address (fun p a => { p with address := a })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def Company.addressLens : LawfulLens Company Address :=
  Lens.mkLawful Company.address (fun c a => { c with address := a })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def Company.employeesLens : LawfulLens Company (List Person) :=
  Lens.mkLawful Company.employees (fun c ps => { c with employees := ps })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def optionPrism {α : Type} : Prism (Option α) α :=
  { matchS := fun x => match x with | some a => Sum.inl a | none => Sum.inr none
    build := some }

def optionStringPrism : Prism (Option String) String :=
  optionPrism

def testAddress : Address :=
  { street := "123 Main St", city := "Anytown", zip := "12345" }

def testPerson : Person :=
  { name := "Alice", age := 30, email := "alice@example.com" }

def testPersonWithAddress : PersonWithAddress :=
  { name := "Alice", age := 30, address := testAddress }

def testCompany : Company :=
  { name := "Acme Corp", address := testAddress, employees := [testPerson] }

/-- Lens into `Person.name` through `Option Person` (defaults when `none`). -/
def optionPersonNameLens (defaultName : String) : Lens (Option Person) String :=
  { get := fun op => match op with | some p => p.name | none => defaultName
    set := fun op name => match op with | some p => some { p with name := name } | none => op }

abbrev nameLens : Lens Person String := Person.nameLens
abbrev ageLens : Lens Person Nat := Person.ageLens
abbrev emailLens : Lens Person String := Person.emailLens
abbrev streetLens : Lens Address String := Address.streetLens
abbrev personAddressLens : Lens PersonWithAddress Address := PersonWithAddress.addressLens

def streetLens' : Lens PersonWithAddress String :=
  personAddressLens ∘ₗ streetLens

def lensPrismComp : Lens (Option Person) String :=
  optionPersonNameLens "Unknown"

end Tests.Common
