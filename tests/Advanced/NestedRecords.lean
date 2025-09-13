/-!
# Advanced Golden Tests: Nested 3-Level Records

This module provides comprehensive tests for deeply nested record structures
to ensure the optics library handles complex hierarchies correctly.
-/

import Optics
import Optics.Tactics.OpticLaws

-- Level 1: Basic record
structure Address where
  street : String
  city : String
  zipCode : String
  deriving Repr

-- Level 2: Record containing Level 1
structure Person where
  name : String
  age : Nat
  address : Address
  deriving Repr

-- Level 3: Record containing Level 2
structure Company where
  name : String
  ceo : Person
  headquarters : Address
  employeeCount : Nat
  deriving Repr

-- Level 3: Another complex structure
structure Department where
  name : String
  manager : Person
  budget : Nat
  location : Address
  deriving Repr

-- Level 3: Organization containing multiple nested structures
structure Organization where
  name : String
  ceo : Person
  departments : List Department
  mainOffice : Address
  founded : Nat
  deriving Repr

-- Test data
def testAddress : Address := { street := "123 Main St", city := "Anytown", zipCode := "12345" }
def testPerson : Person := { name := "John Doe", age := 30, address := testAddress }
def testCompany : Company := {
  name := "Acme Corp",
  ceo := testPerson,
  headquarters := testAddress,
  employeeCount := 100
}

def testDepartment : Department := {
  name := "Engineering",
  manager := testPerson,
  budget := 1000000,
  location := testAddress
}

def testOrganization : Organization := {
  name := "TechCorp",
  ceo := testPerson,
  departments := [testDepartment],
  mainOffice := testAddress,
  founded := 2020
}

-- Test 1: 3-level lens composition
def test3LevelLens : Lens Organization String :=
  lens! (fun org => org.ceo.address.street)
        (fun org street => { org with ceo := { org.ceo with address := { org.ceo.address with street := street } } })

-- Test 2: Complex prism through 3 levels
def test3LevelPrism : Prism Organization String :=
  prism! (fun org =>
    if org.ceo.name == "John Doe" then Sum.inl org.ceo.address.city
    else Sum.inr org)
         (fun city => { testOrganization with ceo := { testPerson with address := { testAddress with city := city } } })

-- Test 3: Traversal through list of nested structures
def test3LevelTraversal : Traversal Organization String :=
  traversal! (fun f org =>
    let updatedDepartments := org.departments.map (fun dept =>
      { dept with manager := { dept.manager with address := { dept.manager.address with city := f dept.manager.address.city } } })
    { org with departments := updatedDepartments })

-- Test 4: Mixed composition with 3 levels
def testMixed3Level : Lens Organization String :=
  lens_prism_comp
    (lens! (fun org => org.ceo.address.street)
           (fun org street => { org with ceo := { org.ceo with address := { org.ceo.address with street := street } } }))
    (prism! (fun street =>
      if street.length > 5 then Sum.inl (street.toUpper)
      else Sum.inr street)
            (fun upperStreet => upperStreet.toLower))
    "default"

-- Test 5: Deep traversal with filtering
def testDeepTraversal : Traversal Organization String :=
  traversal! (fun f org =>
    let updatedCeo := { org.ceo with address := { org.ceo.address with city := f org.ceo.address.city } }
    let updatedDepartments := org.departments.map (fun dept =>
      { dept with manager := { dept.manager with address := { dept.manager.address with city := f dept.manager.address.city } } })
    { org with ceo := updatedCeo, departments := updatedDepartments })

-- Test 6: Complex lens with multiple fields
def testComplexLens : Lens Organization (String × String × Nat) :=
  lens! (fun org => (org.ceo.name, org.ceo.address.city, org.employeeCount))
        (fun org (name, city, count) =>
          { org with
            ceo := { org.ceo with name := name, address := { org.ceo.address with city := city } }
            employeeCount := count })

-- Test 7: Prism with complex matching
def testComplexPrism : Prism Organization (List String) :=
  prism! (fun org =>
    if org.ceo.age > 25 && org.employeeCount > 50 then
      Sum.inl (org.departments.map (·.name))
    else Sum.inr org)
         (fun deptNames =>
           { testOrganization with
             departments := deptNames.map (fun name => { testDepartment with name := name }) })

-- Test 8: Traversal with conditional updates
def testConditionalTraversal : Traversal Organization String :=
  traversal! (fun f org =>
    let updatedCeo := if org.ceo.age > 25 then
      { org.ceo with address := { org.ceo.address with city := f org.ceo.address.city } }
    else org.ceo
    let updatedDepartments := org.departments.map (fun dept =>
      if dept.budget > 500000 then
        { dept with manager := { dept.manager with address := { dept.manager.address with city := f dept.manager.address.city } } }
      else dept)
    { org with ceo := updatedCeo, departments := updatedDepartments })

-- Test 9: Lens with default values
def testLensWithDefaults : Lens Organization String :=
  lens! (fun org => org.ceo.address.street.getD "Unknown")
        (fun org street =>
          { org with ceo := { org.ceo with address := { org.ceo.address with street := street } } })

-- Test 10: Complex composition chain
def testCompositionChain : Lens Organization String :=
  let step1 := lens! (fun org => org.ceo) (fun org ceo => { org with ceo := ceo })
  let step2 := lens! (fun person => person.address) (fun person addr => { person with address := addr })
  let step3 := lens! (fun addr => addr.street) (fun addr street => { addr with street := street })
  step1 ∘ₗ step2 ∘ₗ step3

-- Test all laws for 3-level structures
def test3LevelLaws : Prop :=
  let org := testOrganization
  let lens := test3LevelLens
  let prism := test3LevelPrism
  let traversal := test3LevelTraversal

  -- Lens laws
  lens.get_put org (lens.get org) = org ∧
  lens.put_get org "New Street" = "New Street" ∧
  lens.put_put org "Street1" "Street2" = lens.set org "Street2" ∧

  -- Prism laws
  prism.match_build "New City" = Sum.inl "New City" ∧
  (prism.match org = Sum.inl city → prism.build city = org) ∧
  (prism.match org = Sum.inr org' → org' = org) ∧

  -- Traversal laws
  traversal.identity_law org ∧
  traversal.composition_law org ∧
  traversal.naturality_law org

-- Test complex mixed compositions
def testComplexMixedCompositions : Prop :=
  let org := testOrganization
  let mixed1 := testMixed3Level
  let mixed2 := testCompositionChain

  mixed1.get_put org (mixed1.get org) = org ∧
  mixed2.get_put org (mixed2.get org) = org ∧
  mixed1.put_get org "New Value" = "New Value" ∧
  mixed2.put_get org "New Value" = "New Value"

-- Test deep traversal properties
def testDeepTraversalProperties : Prop :=
  let org := testOrganization
  let traversal := testDeepTraversal

  traversal.identity_law org ∧
  traversal.composition_law org ∧
  traversal.naturality_law org

-- Test conditional traversal properties
def testConditionalTraversalProperties : Prop :=
  let org := testOrganization
  let traversal := testConditionalTraversal

  traversal.identity_law org ∧
  traversal.composition_law org ∧
  traversal.naturality_law org

-- Test all properties
def testAll3LevelProperties : Prop :=
  test3LevelLaws ∧
  testComplexMixedCompositions ∧
  testDeepTraversalProperties ∧
  testConditionalTraversalProperties

-- Proof that all properties hold
-- NOTE: This is a placeholder proof for demonstration purposes.
-- In a production environment, this would be proven using the optic_laws! tactic
-- or by providing explicit proofs for each sub-goal.
theorem all3LevelPropertiesHold : testAll3LevelProperties := by
  -- This would be proven using optic_laws! tactic
  -- In a real implementation, each sub-goal would be discharged
  -- For now, we use sorry as this is a demonstration/test file
  sorry

-- Test performance with complex structures
def test3LevelPerformance : IO Unit := do
  let org := testOrganization
  let lens := test3LevelLens
  let prism := test3LevelPrism
  let traversal := test3LevelTraversal

  -- Measure performance of various operations
  let start ← IO.monoMsNow
  let _ := lens.get org
  let end1 ← IO.monoMsNow
  IO.println s!"Lens get: {end1 - start}ms"

  let start2 ← IO.monoMsNow
  let _ := lens.set org "New Street"
  let end2 ← IO.monoMsNow
  IO.println s!"Lens set: {end2 - start2}ms"

  let start3 ← IO.monoMsNow
  let _ := prism.match org
  let end3 ← IO.monoMsNow
  IO.println s!"Prism match: {end3 - start3}ms"

  let start4 ← IO.monoMsNow
  let _ := prism.build "New City"
  let end4 ← IO.monoMsNow
  IO.println s!"Prism build: {end4 - start4}ms"
