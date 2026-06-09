/-
# Automation layer

Tactics, macros, and record-derivation helpers. Import explicitly when needed;
not part of the stable public API.

After `import Optics.Automation`, use `open Optics` to bring `lens!`, `prism!`,
`traversal!`, and `optic_laws!` into scope.
-/

import Optics.Tactics.OpticLaws
import Optics.Tactics.LocalSimp
import Optics.Macros.MkBang
import Optics.Stdlib.Records

-- `optic_laws!`, `lens!`, `prism!`, `traversal!`, and `derive_lens` live here after import.
