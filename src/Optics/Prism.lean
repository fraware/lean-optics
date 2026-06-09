/-
# Prisms

Stable import surface for prisms.
-/

import Optics.Concrete.Prism

export Optics (Prism)
export Optics.Prism (of preview id comp WellFormed toOptic)
export Optics.Prism (match_build build_match no_match_id)
