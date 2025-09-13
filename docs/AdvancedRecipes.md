# Advanced Optics Recipes

This document provides comprehensive recipes for advanced usage patterns with the lean-optics library.

## Table of Contents

1. [Complex Lens Compositions](#complex-lens-compositions)
2. [Advanced Prism Patterns](#advanced-prism-patterns)
3. [Traversal Optimization](#traversal-optimization)
4. [Performance-Critical Patterns](#performance-critical-patterns)
5. [Error Handling Strategies](#error-handling-strategies)
6. [Custom Optic Types](#custom-optic-types)
7. [Integration Patterns](#integration-patterns)

## Complex Lens Compositions

### Recipe 1: Deep Nested Record Access

```lean
-- For deeply nested records, use composition chains
def deepAccess : Lens Organization String :=
  let ceoLens := lens! (fun org => org.ceo) (fun org ceo => { org with ceo := ceo })
  let addressLens := lens! (fun person => person.address) (fun person addr => { person with address := addr })
  let streetLens := lens! (fun addr => addr.street) (fun addr street => { addr with street := street })
  ceoLens ∘ₗ addressLens ∘ₗ streetLens

-- Alternative: Direct construction for better performance
def deepAccessDirect : Lens Organization String :=
  lens! (fun org => org.ceo.address.street) 
        (fun org street => { org with ceo := { org.ceo with address := { org.ceo.address with street := street } } })
```

### Recipe 2: Conditional Lens Access

```lean
-- Use prisms for conditional access
def conditionalAccess : Prism Person String :=
  prism! (fun person => 
    if person.age > 18 then Sum.inl person.name
    else Sum.inr person)
         (fun name => { testPerson with name := name })

-- Compose with lens for conditional updates
def conditionalUpdate : Lens Person (Option String) :=
  lens! (fun person => if person.age > 18 then some person.name else none)
        (fun person nameOpt => 
          match nameOpt with
          | some name => { person with name := name }
          | none => person)
```

### Recipe 3: Multi-Field Lens Updates

```lean
-- Update multiple fields atomically
def multiFieldUpdate : Lens Person (String × Nat) :=
  lens! (fun person => (person.name, person.age))
        (fun person (name, age) => { person with name := name, age := age })

-- Use with over for transformations
def transformPerson (f : String → String) (g : Nat → Nat) : Person → Person :=
  multiFieldUpdate.over (fun (name, age) => (f name, g age))
```

## Advanced Prism Patterns

### Recipe 4: Error Recovery Prisms

```lean
-- Prism that recovers from errors
def errorRecoveryPrism : Prism Task Task :=
  prism! (fun task => 
    if task.status == Status.error then
      Sum.inl { task with status := Status.pending, priority := Priority.low }
    else Sum.inr task)
         (fun task => { task with status := Status.error })

-- Chain with other prisms for complex recovery
def complexRecovery : Prism Task Task :=
  prism_comp errorRecoveryPrism activeTaskPrism
```

### Recipe 5: Validation Prisms

```lean
-- Prism that validates data
def validationPrism : Prism String String :=
  prism! (fun str => 
    if str.length > 0 && str.length < 100 then Sum.inl str
    else Sum.inr str)
         (fun str => str)

-- Use with error handling
def safeValidation : Prism String (Option String) :=
  prism! (fun str => 
    if str.length > 0 && str.length < 100 then Sum.inl (some str)
    else Sum.inr str)
         (fun strOpt => strOpt.getD "default")
```

### Recipe 6: Transformation Prisms

```lean
-- Prism that transforms data
def transformationPrism : Prism String String :=
  prism! (fun str => 
    if str.length > 5 then Sum.inl (str.toUpper)
    else Sum.inr str)
         (fun upperStr => upperStr.toLower)

-- Chain transformations
def transformationChain : Prism String String :=
  prism_comp validationPrism transformationPrism
```

## Traversal Optimization

### Recipe 7: Selective Traversals

```lean
-- Traverse only specific elements
def selectiveTraversal : Traversal (List Task) Task :=
  traversal! (fun f tasks => 
    tasks.map (fun task => 
      if task.priority == Priority.high then f task
      else task))

-- Use with filtering
def filteredTraversal : Traversal (List Task) Task :=
  traversal! (fun f tasks => 
    tasks.filter (fun task => task.status == Status.active) |>.map f)
```

### Recipe 8: Parallel Traversals

```lean
-- Traverse multiple structures in parallel
def parallelTraversal : Traversal (Project × Project) Task :=
  traversal! (fun f (proj1, proj2) => 
    let updatedTasks1 := proj1.tasks.map f
    let updatedTasks2 := proj2.tasks.map f
    ({ proj1 with tasks := updatedTasks1 }, { proj2 with tasks := updatedTasks2 }))
```

### Recipe 9: Conditional Traversals

```lean
-- Traverse based on conditions
def conditionalTraversal : Traversal Project Task :=
  traversal! (fun f project => 
    if project.status == Status.active then
      { project with tasks := project.tasks.map f }
    else project)
```

## Performance-Critical Patterns

### Recipe 10: Cached Lens Access

```lean
-- Cache expensive computations
def cachedLens : Lens Project (List String) :=
  lens! (fun project => 
    -- Cache the result of expensive computation
    project.tasks.map (·.title) |>.sort)
         (fun project titles => 
           -- Reconstruct with sorted titles
           { project with tasks := project.tasks.sortBy (·.title) })
```

### Recipe 11: Lazy Traversals

```lean
-- Use lazy evaluation for large structures
def lazyTraversal : Traversal (List Project) Task :=
  traversal! (fun f projects => 
    projects.map (fun project => 
      { project with tasks := project.tasks.map f }))
```

### Recipe 12: Batch Operations

```lean
-- Batch multiple operations together
def batchUpdate : Lens Project Project :=
  lens! (fun project => project)
        (fun project => 
          let updatedTasks := project.tasks.map (fun task => 
            { task with status := Status.active, priority := Priority.medium })
          { project with tasks := updatedTasks })
```

## Error Handling Strategies

### Recipe 13: Safe Lens Access

```lean
-- Safe access with default values
def safeLens : Lens Person (Option String) :=
  lens! (fun person => some person.name)
        (fun person nameOpt => 
          match nameOpt with
          | some name => { person with name := name }
          | none => person)
```

### Recipe 14: Error Propagation

```lean
-- Propagate errors through compositions
def errorPropagatingLens : Lens Person (Except String String) :=
  lens! (fun person => 
    if person.name.length > 0 then Except.ok person.name
    else Except.error "Empty name")
         (fun person nameResult => 
           match nameResult with
           | Except.ok name => { person with name := name }
           | Except.error _ => person)
```

### Recipe 15: Recovery Strategies

```lean
-- Multiple recovery strategies
def recoveryLens : Lens Person String :=
  lens! (fun person => 
    if person.name.length > 0 then person.name
    else "Unknown")
         (fun person name => 
           if name == "Unknown" then person
           else { person with name := name })
```

## Custom Optic Types

### Recipe 16: Custom Lens Types

```lean
-- Define custom lens types for specific domains
structure DatabaseLens (S A : Type) where
  select : S → A
  update : S → A → S
  constraints : List (A → Bool)

def databaseLens (select : S → A) (update : S → A → S) (constraints : List (A → Bool)) : DatabaseLens S A :=
  { select, update, constraints }
```

### Recipe 17: Custom Prism Types

```lean
-- Define custom prism types with validation
structure ValidatedPrism (S A : Type) where
  match : S → Sum A S
  build : A → S
  validator : A → Bool

def validatedPrism (match : S → Sum A S) (build : A → S) (validator : A → Bool) : ValidatedPrism S A :=
  { match, build, validator }
```

### Recipe 18: Custom Traversal Types

```lean
-- Define custom traversal types with effects
structure EffectfulTraversal (S A : Type) (M : Type → Type) [Monad M] where
  traverse : (A → M A) → S → M S
  effects : List (S → M Unit)

def effectfulTraversal (traverse : (A → M A) → S → M S) (effects : List (S → M Unit)) : EffectfulTraversal S A M :=
  { traverse, effects }
```

## Integration Patterns

### Recipe 19: Database Integration

```lean
-- Integrate with database operations
def databaseLens : Lens DatabaseRecord String :=
  lens! (fun record => record.name)
        (fun record name => 
          -- Update database
          database.update record.id name
          { record with name := name })
```

### Recipe 20: API Integration

```lean
-- Integrate with external APIs
def apiLens : Lens ApiResponse String :=
  lens! (fun response => response.data)
        (fun response data => 
          -- Send to API
          api.update response.id data
          { response with data := data })
```

### Recipe 21: Configuration Integration

```lean
-- Integrate with configuration systems
def configLens : Lens Config String :=
  lens! (fun config => config.getValue "key")
        (fun config value => 
          -- Update configuration
          config.setValue "key" value
          { config with values := config.values.insert "key" value })
```

## Best Practices

### Performance Tips

1. **Use direct construction** for simple cases instead of composition chains
2. **Cache expensive computations** in lens getters
3. **Use selective traversals** to avoid unnecessary work
4. **Batch operations** when possible
5. **Profile your code** to identify bottlenecks

### Error Handling Tips

1. **Use prisms for optional access** instead of throwing exceptions
2. **Provide meaningful error messages** in validation prisms
3. **Use recovery strategies** for common failure modes
4. **Test error paths** thoroughly
5. **Document error conditions** clearly

### Testing Tips

1. **Test all law combinations** for complex compositions
2. **Use property-based testing** for random inputs
3. **Test performance** with realistic data sizes
4. **Test error conditions** explicitly
5. **Use golden tests** for complex scenarios

### Maintenance Tips

1. **Keep compositions simple** and readable
2. **Document complex patterns** clearly
3. **Use type aliases** for complex types
4. **Refactor regularly** to improve clarity
5. **Monitor performance** continuously
