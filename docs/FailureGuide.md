# Optics Failure Guide

This document provides comprehensive troubleshooting guidance for common issues and failure scenarios when using the lean-optics library.

## Table of Contents

1. [Common Error Messages](#common-error-messages)
2. [Tactic Failures](#tactic-failures)
3. [Performance Issues](#performance-issues)
4. [Type Errors](#type-errors)
5. [Law Violations](#law-violations)
6. [Debugging Strategies](#debugging-strategies)
7. [Advanced Failure Scenarios](#advanced-failure-scenarios)

## Common Error Messages

### Error: "optic_laws! tactic failed"

**Symptoms:**
- The `optic_laws!` tactic fails to discharge a proof obligation
- Error message indicates tactic timeout or failure

**Causes:**
1. **Complex goal structure** that the tactic cannot handle
2. **Missing lemmas** in the simplification set
3. **Type mismatch** in the goal
4. **Infinite recursion** in the proof search

**Solutions:**
```lean
-- 1. Simplify the goal manually first
theorem myLensLaw : lens.get_put s a := by
  simp only [lens.get, lens.set]
  -- Add manual steps if needed
  optic_laws!

-- 2. Add missing lemmas to the simp set
@[simp] lemma myCustomLemma : myProperty := by sorry

-- 3. Use more specific tactics
theorem myLensLaw : lens.get_put s a := by
  cases s
  simp
  optic_laws!

-- 4. Check for type mismatches
theorem myLensLaw : lens.get_put s a := by
  -- Ensure types match
  have : s : S := s
  have : a : A := a
  optic_laws!
```

### Error: "type mismatch at application"

**Symptoms:**
- Type error when applying optics
- Mismatch between expected and actual types

**Causes:**
1. **Incorrect type parameters** in optic construction
2. **Missing type annotations**
3. **Implicit type inference failure**

**Solutions:**
```lean
-- 1. Add explicit type annotations
def myLens : Lens Person String :=
  lens! (fun (p : Person) => p.name) 
        (fun (p : Person) (n : String) => { p with name := n })

-- 2. Check type parameters
def myLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 3. Use type ascriptions
def myLens : Lens Person String :=
  lens! (fun p => (p.name : String)) 
        (fun p n => { p with name := (n : String) })
```

### Error: "unknown identifier"

**Symptoms:**
- Error about unknown identifier
- Missing import or definition

**Causes:**
1. **Missing import** statement
2. **Typo in identifier name**
3. **Scope issue** with identifier

**Solutions:**
```lean
-- 1. Add missing imports
import Optics
import Optics.Tactics.OpticLaws

-- 2. Check spelling
def myLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 3. Check scope
namespace MyNamespace
  def myLens : Lens Person String :=
    lens! (fun p => p.name) (fun p n => { p with name := n })
end MyNamespace
```

## Tactic Failures

### optic_laws! Stalls or Times Out

**Symptoms:**
- Tactic runs for a long time without completing
- Timeout error after maximum steps

**Causes:**
1. **Infinite proof search** due to circular dependencies
2. **Complex goal structure** that requires manual intervention
3. **Missing lemmas** that prevent simplification
4. **Performance issues** with large terms

**Solutions:**
```lean
-- 1. Increase timeout
set_option optics.timeoutMs 1000

-- 2. Use more specific tactics
theorem myLensLaw : lens.get_put s a := by
  simp only [lens.get, lens.set, myCustomLemma]
  optic_laws!

-- 3. Break down complex goals
theorem myLensLaw : lens.get_put s a := by
  cases s
  simp
  optic_laws!

-- 4. Use manual proof steps
theorem myLensLaw : lens.get_put s a := by
  rw [lens.get, lens.set]
  simp
  -- Add manual steps if needed
  optic_laws!
```

### Tactic Fails on Specific Goal Types

**Symptoms:**
- Tactic works for some goals but fails on others
- Inconsistent behavior across different goal types

**Causes:**
1. **Goal type not recognized** by the tactic
2. **Missing case handling** in the tactic implementation
3. **Type-specific issues** that require special handling

**Solutions:**
```lean
-- 1. Check goal type
theorem myLensLaw : lens.get_put s a := by
  -- Debug the goal type
  trace_state
  optic_laws!

-- 2. Use type-specific tactics
theorem myLensLaw : lens.get_put s a := by
  match goal with
  | `(lens.get_put _ _) => optic_laws!
  | _ => simp; optic_laws!

-- 3. Add custom handling
theorem myLensLaw : lens.get_put s a := by
  -- Custom proof for specific case
  simp only [lens.get, lens.set]
  rfl
```

## Performance Issues

### Slow Tactic Execution

**Symptoms:**
- Tactics take a long time to complete
- Performance degrades with larger terms

**Causes:**
1. **Inefficient proof search** strategy
2. **Large term sizes** causing memory issues
3. **Complex goal structures** requiring extensive search
4. **Missing optimizations** in the tactic implementation

**Solutions:**
```lean
-- 1. Optimize proof search
set_option optics.maxSteps 128

-- 2. Use more efficient tactics
theorem myLensLaw : lens.get_put s a := by
  simp only [lens.get, lens.set]
  rfl

-- 3. Break down complex goals
theorem myLensLaw : lens.get_put s a := by
  cases s
  simp
  optic_laws!

-- 4. Use caching for repeated computations
def cachedLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })
```

### Memory Issues

**Symptoms:**
- Out of memory errors
- Slow performance due to memory pressure

**Causes:**
1. **Large term sizes** in proofs
2. **Inefficient data structures** in the tactic
3. **Memory leaks** in the implementation
4. **Excessive copying** of large terms

**Solutions:**
```lean
-- 1. Use more efficient data structures
def efficientLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 2. Avoid unnecessary copying
def efficientLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 3. Use lazy evaluation
def lazyLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })
```

## Type Errors

### Type Mismatch in Lens Construction

**Symptoms:**
- Type error when constructing lenses
- Mismatch between expected and actual types

**Causes:**
1. **Incorrect type parameters** in lens construction
2. **Missing type annotations**
3. **Implicit type inference failure**

**Solutions:**
```lean
-- 1. Add explicit type annotations
def myLens : Lens Person String :=
  lens! (fun (p : Person) => p.name) 
        (fun (p : Person) (n : String) => { p with name := n })

-- 2. Check type parameters
def myLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 3. Use type ascriptions
def myLens : Lens Person String :=
  lens! (fun p => (p.name : String)) 
        (fun p n => { p with name := (n : String) })
```

### Type Mismatch in Prism Construction

**Symptoms:**
- Type error when constructing prisms
- Mismatch in Sum types

**Causes:**
1. **Incorrect Sum type construction**
2. **Missing type annotations**
3. **Implicit type inference failure**

**Solutions:**
```lean
-- 1. Add explicit type annotations
def myPrism : Prism Person String :=
  prism! (fun (p : Person) => 
    if p.age > 18 then Sum.inl (p.name : String)
    else Sum.inr p)
         (fun (n : String) => { testPerson with name := n })

-- 2. Check Sum type construction
def myPrism : Prism Person String :=
  prism! (fun p => 
    if p.age > 18 then Sum.inl p.name
    else Sum.inr p)
         (fun n => { testPerson with name := n })

-- 3. Use type ascriptions
def myPrism : Prism Person String :=
  prism! (fun p => 
    if p.age > 18 then Sum.inl (p.name : String)
    else Sum.inr p)
         (fun n => { testPerson with name := (n : String) })
```

## Law Violations

### Lens Laws Not Satisfied

**Symptoms:**
- Lens laws fail to hold
- Unexpected behavior in lens operations

**Causes:**
1. **Incorrect implementation** of get/set functions
2. **Side effects** in get/set functions
3. **Type mismatches** in law statements

**Solutions:**
```lean
-- 1. Check implementation
def myLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 2. Verify laws manually
theorem myLensGetPut : myLens.get_put s a := by
  simp only [myLens.get, myLens.set]
  rfl

-- 3. Use optic_laws! to verify
theorem myLensGetPut : myLens.get_put s a := by
  optic_laws!
```

### Prism Laws Not Satisfied

**Symptoms:**
- Prism laws fail to hold
- Unexpected behavior in prism operations

**Causes:**
1. **Incorrect implementation** of match/build functions
2. **Side effects** in match/build functions
3. **Type mismatches** in law statements

**Solutions:**
```lean
-- 1. Check implementation
def myPrism : Prism Person String :=
  prism! (fun p => 
    if p.age > 18 then Sum.inl p.name
    else Sum.inr p)
         (fun n => { testPerson with name := n })

-- 2. Verify laws manually
theorem myPrismMatchBuild : myPrism.match_build a := by
  simp only [myPrism.match, myPrism.build]
  rfl

-- 3. Use optic_laws! to verify
theorem myPrismMatchBuild : myPrism.match_build a := by
  optic_laws!
```

## Debugging Strategies

### Enable Tracing

```lean
-- 1. Enable tactic tracing
set_option trace.optics true

-- 2. Enable simplification tracing
set_option trace.simp true

-- 3. Enable goal tracing
theorem myLensLaw : lens.get_put s a := by
  trace_state
  optic_laws!
```

### Use Debug Tactics

```lean
-- 1. Debug the goal
theorem myLensLaw : lens.get_put s a := by
  trace_state
  simp only [lens.get, lens.set]
  trace_state
  optic_laws!

-- 2. Debug specific terms
theorem myLensLaw : lens.get_put s a := by
  have h1 := lens.get s
  have h2 := lens.set s a
  trace h1
  trace h2
  optic_laws!
```

### Check Intermediate Steps

```lean
-- 1. Break down complex proofs
theorem myLensLaw : lens.get_put s a := by
  simp only [lens.get, lens.set]
  -- Check intermediate state
  trace_state
  rfl

-- 2. Use have statements
theorem myLensLaw : lens.get_put s a := by
  have h1 := lens.get s
  have h2 := lens.set s a
  have h3 := lens.get h2
  -- Check that h1 = h3
  rw [h1, h3]
  rfl
```

## Advanced Failure Scenarios

### Complex Composition Failures

**Symptoms:**
- Complex optic compositions fail
- Unexpected behavior in composed optics

**Causes:**
1. **Type mismatches** in composition
2. **Missing composition laws**
3. **Performance issues** with complex compositions

**Solutions:**
```lean
-- 1. Check composition types
def complexLens : Lens Organization String :=
  let step1 := lens! (fun org => org.ceo) (fun org ceo => { org with ceo := ceo })
  let step2 := lens! (fun person => person.address) (fun person addr => { person with address := addr })
  let step3 := lens! (fun addr => addr.street) (fun addr street => { addr with street := street })
  step1 ∘ₗ step2 ∘ₗ step3

-- 2. Verify composition laws
theorem complexLensGetPut : complexLens.get_put s a := by
  optic_laws!

-- 3. Use direct construction for better performance
def complexLensDirect : Lens Organization String :=
  lens! (fun org => org.ceo.address.street) 
        (fun org street => { org with ceo := { org.ceo with address := { org.ceo.address with street := street } } })
```

### Performance Degradation

**Symptoms:**
- Performance degrades with larger inputs
- Memory usage increases significantly

**Causes:**
1. **Inefficient algorithms** in the implementation
2. **Memory leaks** in the tactic
3. **Large term sizes** causing performance issues

**Solutions:**
```lean
-- 1. Use more efficient implementations
def efficientLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 2. Avoid unnecessary computations
def efficientLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })

-- 3. Use caching for repeated computations
def cachedLens : Lens Person String :=
  lens! (fun p => p.name) (fun p n => { p with name := n })
```

### Integration Issues

**Symptoms:**
- Issues when integrating with other libraries
- Type conflicts with external code

**Causes:**
1. **Type conflicts** with external libraries
2. **Missing imports** or dependencies
3. **Version compatibility** issues

**Solutions:**
```lean
-- 1. Check imports
import Optics
import OtherLibrary

-- 2. Use type aliases to avoid conflicts
def MyLens := Lens Person String

-- 3. Use qualified names
def myLens : Optics.Lens Person String :=
  Optics.lens! (fun p => p.name) (fun p n => { p with name := n })
```

## Getting Help

### Reporting Issues

When reporting issues, please include:

1. **Minimal reproduction case** that demonstrates the problem
2. **Expected behavior** vs actual behavior
3. **Error messages** and stack traces
4. **Environment information** (Lean version, OS, etc.)
5. **Steps to reproduce** the issue

### Debugging Checklist

Before reporting an issue, check:

1. **Are all imports present?**
2. **Are type annotations correct?**
3. **Are the laws actually satisfied?**
4. **Is the goal type recognized by the tactic?**
5. **Are there any performance issues?**
6. **Is the error reproducible?**
7. **Have you tried the suggested solutions?**

### Community Resources

- **GitHub Issues**: Report bugs and request features
- **Discord**: Get help from the community
- **Documentation**: Check the official documentation
- **Examples**: Look at the example code in the repository
