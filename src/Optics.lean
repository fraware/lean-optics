/-
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

import Optics.Core.Profunctor
import Optics.Core.StrongChoiceTrav
import Optics.Concrete.Lens
import Optics.Concrete.Prism
import Optics.Concrete.Traversal
import Optics.Compose
import Optics.Tactics.OpticLaws
import Optics.Macros.MkBang
import Optics.Stdlib.Records
import Optics.Stdlib.Containers
import Optics.Telemetry.Core
import Optics.Telemetry.Timing
import Optics.Verification.Determinism
import Optics.Verification.Performance

-- Core classes (declared under `namespace Optics` in each file)
export Optics (Profunctor)
export Optics (Strong Choice Traversing)

-- Concrete optics
export Optics (Lens Prism Traversal)

-- Composition
export Optics (lens_prism_comp prism_lens_comp lens_traversal_comp traversal_lens_comp prism_traversal_comp traversal_prism_comp)

-- Tactics/macros/elabs (`optic_laws!`, `lens!`, `derive_lens`, …) live in `Optics` after import; they are not `export`able as constants.

-- Stdlib helpers
export Optics (listTraversal arrayTraversal optionTraversal sumTraversal)

-- Telemetry (opt-in)
export Optics.Telemetry (withTiming classifyGoal)

-- Verification
export Optics.Verification (testDeterminism testHypothesisOrderIndependence)
export Optics.Verification (runPerformanceBenchmark analyzePerformance)
