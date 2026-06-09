/-
# Lean Optics

Industrial-quality optics with law-carrying composition. This module exports the
stable public API only: core classes, concrete optics, and composition.

For macros and tactics, import `Optics.Automation`. For telemetry, verification,
and container traversals, import `Optics.Experimental`.

## Quick Start (stable, no macros)

```lean
import Optics
import Optics.Examples.LawfulLens

def updateName (p : Person) : Person :=
  nameLens.over (fun n => n.toUpper)
```

## Features

- **Core Types**: Profunctor, Strong, Choice, Traversing classes
- **Concrete Optics**: Lens, Prism, Traversal structures
- **Lawful Lens**: `LawfulLens` with inline `get_set`, `set_get`, `set_set`
- **Composition**: Law-preserving composition operators
-/

import Optics.Core
import Optics.Lens
import Optics.Prism
import Optics.Traversal
import Optics.Compose

-- Core classes
export Optics (Profunctor)
export Optics (Strong Choice Traversing)

-- Concrete optics
export Optics (Lens LawfulLens)
export Optics (Prism Traversal)

-- Composition
export Optics (lens_prism_comp prism_lens_comp lens_traversal_comp traversal_lens_comp prism_traversal_comp traversal_prism_comp)
export Optics (lens_comp_preserves_laws traversal_comp_preserves_laws)
