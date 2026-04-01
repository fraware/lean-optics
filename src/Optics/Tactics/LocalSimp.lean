/-
# Local Simplification Kernel

Simp configuration surface for `optic_laws!` (extend as needed).
-/

import Lean

namespace Optics

/-- Default simp theorems bundle used when `optic_laws!` runs `simp`. -/
def opticSimpSet : Lean.Meta.SimpTheoremsArray := #[]

end Optics
