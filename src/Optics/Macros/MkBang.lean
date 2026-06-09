/-
# Macros for Creating Optics

`lens!`, `prism!`, and `traversal!` expand to the corresponding `of` constructors.
-/

import Lean
import Optics.Concrete.Lens
import Optics.Concrete.Prism
import Optics.Concrete.Traversal

namespace Optics

macro "lens!" get:term set:term : term =>
  `(Lens.of $get $set)

macro "prism!" m:term b:term : term =>
  `(Prism.of $m $b)

macro "traversal!" tr:term : term =>
  `(Traversal.of $tr)

end Optics
