/-
# Macros for Creating Optics

`lens!`, `prism!`, and `traversal!` expand to the corresponding `mk` constructors.
-/

import Lean
import Optics.Concrete.Lens
import Optics.Concrete.Prism
import Optics.Concrete.Traversal

namespace Optics

macro "lens!" get:term set:term : term =>
  `(Lens.mk $get $set)

macro "prism!" m:term b:term : term =>
  `(Prism.mk $m $b)

macro "traversal!" tr:term : term =>
  `(Traversal.mk $tr)

end Optics
