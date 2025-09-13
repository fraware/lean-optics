/-!
# Lean Optics

Industrial-quality optics over profunctors with law-carrying composition and automation
to discharge standard lens/prism/traversal laws.

## Quick Start

```lean
import Optics

-- Define a record
structure Person where
  name : String
  age : Nat

-- Create a lens for the name field
def nameLens : Lens Person String :=
  lens! Person.name (fun p n => { p with name := n })

-- Use the lens
def updateName (p : Person) : Person :=
  nameLens.over (fun n => n.toUpper)
```

## Features

- **Core Types**: Profunctor, Strong, Choice, Traversing classes
- **Concrete Optics**: Lens, Prism, Traversal structures
- **Composition**: Law-preserving composition operators
- **Automation**: `optic_laws!` tactic for discharging laws
- **Macros**: `lens!`, `prism!`, `traversal!` with law obligations
- **Stdlib**: Record derivation and container traversals
-/

-- Core classes
export Optics.Core.Profunctor (Profunctor)
export Optics.Core.StrongChoiceTrav (Strong Choice Traversing)

-- Concrete optics
export Optics.Concrete.Lens (Lens)
export Optics.Concrete.Prism (Prism)
export Optics.Concrete.Traversal (Traversal)

-- Composition
export Optics.Compose (lens_prism_comp prism_lens_comp lens_traversal_comp traversal_lens_comp prism_traversal_comp traversal_prism_comp)

-- Tactics
export Optics.Tactics.OpticLaws (optic_laws!)

-- Macros
export Optics.Macros.MkBang (lens! prism! traversal!)

-- Stdlib helpers
export Optics.Stdlib.Records (derive_lens derive_lenses)
export Optics.Stdlib.Containers (listTraversal arrayTraversal vectorTraversal optionTraversal sumTraversal)

-- Telemetry (opt-in)
export Optics.Telemetry.Core (OPTICS_TELEMETRY)
export Optics.Telemetry.Timing (withTiming classifyGoal)

-- Verification
export Optics.Verification.Determinism (testDeterminism testHypothesisOrderIndependence)
export Optics.Verification.Performance (runPerformanceBenchmark analyzePerformance)
