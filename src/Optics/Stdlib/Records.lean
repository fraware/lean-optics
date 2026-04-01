/-
# Record Derivation Helpers
-/

import Lean
import Lean.Elab.Command
import Optics.Concrete.Lens

namespace Optics

open Lean Elab Command

/-- Not implemented: generating struct update syntax for arbitrary fields requires extra elaboration. -/
elab "derive_lens" _structName:ident _fieldName:ident : command => do
  throwError "derive_lens is not implemented; define `Lens.mk` for each field explicitly"

elab "derive_lenses " _structName:ident : command => do
  throwError "derive_lenses is not implemented; use explicit `Lens.mk` definitions"

end Optics
