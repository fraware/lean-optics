/-
# Traversals

Stable import surface for traversals.
-/

import Optics.Concrete.Traversal

export Optics (Traversal)
export Optics.Traversal (of comp WellFormed)
export Optics.Traversal (identity_law composition_law naturality_law)
