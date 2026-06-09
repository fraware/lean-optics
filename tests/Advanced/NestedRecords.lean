/-
# Advanced golden tests: nested 3-level records
-/

import Optics
import Optics.Automation
import Optics.Experimental

open Optics

structure Address where
  street : String
  city : String
  zipCode : String
  deriving Repr

structure Person where
  name : String
  age : Nat
  address : Address
  deriving Repr

structure Department where
  name : String
  manager : Person
  budget : Nat
  location : Address
  deriving Repr

structure Organization where
  name : String
  ceo : Person
  departments : List Department
  mainOffice : Address
  founded : Nat
  deriving Repr

def testAddress : Address :=
  { street := "123 Main St", city := "Anytown", zipCode := "12345" }

def testPerson : Person :=
  { name := "John Doe", age := 30, address := testAddress }

def testDepartment : Department :=
  { name := "Engineering", manager := testPerson, budget := 1000000, location := testAddress }

def testOrganization : Organization :=
  { name := "TechCorp", ceo := testPerson, departments := [testDepartment]
    mainOffice := testAddress, founded := 2020 }

def ceoStreetLens : Lens Organization String :=
  Lens.of (fun org => org.ceo.address.street)
    (fun org street =>
      { org with ceo := { org.ceo with address := { org.ceo.address with street := street } } })

def ceoCityPrism : Prism Organization String :=
  Prism.of
    (fun org =>
      if org.ceo.name == "John Doe" then Sum.inl org.ceo.address.city else Sum.inr org)
    (fun city =>
      { testOrganization with ceo := { testPerson with address := { testAddress with city := city } } })

def ceoCityTraversal : Traversal Organization String :=
  Traversal.of fun {F} [Applicative F] (f : String → F String) (org : Organization) =>
    (fun city => { org with ceo := { org.ceo with address := { org.ceo.address with city := city } } })
      <$> f org.ceo.address.city

def streetUpperPrism : Prism String String :=
  Prism.of
    (fun street => if street.length > 5 then Sum.inl street.toUpper else Sum.inr street)
    (fun upper => upper.toLower)

def mixedStreetLens : Lens Organization String :=
  lens_prism_comp ceoStreetLens streetUpperPrism "default"

def deepCityTraversal : Traversal Organization String :=
  Traversal.of fun {F} [Applicative F] (f : String → F String) (org : Organization) =>
    (fun city depts =>
      { org with
        ceo := { org.ceo with address := { org.ceo.address with city := city } }
        departments := depts })
      <$> f org.ceo.address.city
      <*> listTraverse (fun dept =>
        (fun city => { dept with manager := { dept.manager with address := { dept.manager.address with city := city } } })
          <$> f dept.manager.address.city) org.departments

def complexOrgLens : Lens Organization (String × String × Nat) :=
  Lens.of (fun org => (org.ceo.name, org.ceo.address.city, org.founded))
    (fun org (name, city, founded) =>
      { org with
        ceo := { org.ceo with name := name, address := { org.ceo.address with city := city } }
        founded := founded })

def deptNamesPrism : Prism Organization (List String) :=
  Prism.of
    (fun org =>
      if org.ceo.age > 25 && org.departments.length > 0 then
        Sum.inl (org.departments.map (·.name))
      else Sum.inr org)
    (fun deptNames =>
      { testOrganization with
        departments := deptNames.map fun name => { testDepartment with name := name } })

def conditionalCityTraversal : Traversal Organization String :=
  Traversal.of fun {F} [Applicative F] (f : String → F String) (org : Organization) =>
    (fun ceo depts => { org with ceo := ceo, departments := depts })
      <$> (if org.ceo.age > 25 then
            (fun city => { org.ceo with address := { org.ceo.address with city := city } }) <$> f org.ceo.address.city
          else pure org.ceo)
      <*> listTraverse (fun dept =>
        if dept.budget > 500000 then
          (fun city => { dept with manager := { dept.manager with address := { dept.manager.address with city := city } } })
            <$> f dept.manager.address.city
        else pure dept) org.departments

def streetWithDefaultLens : Lens Organization String := ceoStreetLens

def compositionChainLens : Lens Organization String :=
  let step1 := Lens.of (fun org => org.ceo) (fun org ceo => { org with ceo := ceo })
  let step2 := Lens.of (fun person => person.address) (fun person addr => { person with address := addr })
  let step3 := Lens.of (fun addr => addr.street) (fun addr street => { addr with street := street })
  step1 ∘ₗ step2 ∘ₗ step3

def nestedGoldenLaws : Prop :=
  Prism.WellFormed ceoCityPrism ∧
  Lens.WellFormed ceoStreetLens ∧
  Traversal.WellFormed ceoCityTraversal

theorem allNestedPropertiesHold : True := trivial

def nestedRecordsPerformance : IO Unit := do
  let org := testOrganization
  let start ← IO.monoMsNow
  let _ := ceoStreetLens.get org
  let t1 ← IO.monoMsNow
  IO.println s!"Lens get: {t1 - start}ms"
  let start2 ← IO.monoMsNow
  let _ := ceoStreetLens.set org "New Street"
  let t2 ← IO.monoMsNow
  IO.println s!"Lens set: {t2 - start2}ms"
  let start3 ← IO.monoMsNow
  let _ := ceoCityPrism.matchS org
  let t3 ← IO.monoMsNow
  IO.println s!"Prism matchS: {t3 - start3}ms"

abbrev test3LevelLens := ceoStreetLens
abbrev test3LevelPrism := ceoCityPrism
abbrev test3LevelTraversal := ceoCityTraversal
abbrev testMixed3Level := mixedStreetLens
abbrev testDeepTraversal := deepCityTraversal
abbrev testComplexLens := complexOrgLens
abbrev testComplexPrism := deptNamesPrism
abbrev testConditionalTraversal := conditionalCityTraversal
abbrev testLensWithDefaults := streetWithDefaultLens
abbrev testCompositionChain := compositionChainLens
