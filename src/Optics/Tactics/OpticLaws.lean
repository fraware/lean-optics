/-
# Optic Laws Tactic

Implements `optic_laws!` using the core `simp` tactic (extend strategies as needed).
-/

import Lean
import Lean.Elab.Tactic

namespace Optics

open Lean.Elab.Tactic in
elab "optic_laws!" : tactic => do
  evalTactic (← `(tactic| try simp))

end Optics
