/-
# Lawful lenses

Stable import surface for lenses, including the minimal lawful API suitable for
upstream CSLib discussion.
-/

import Optics.Concrete.Lens

export Optics (Lens LawfulLens)
export Optics.Lens (of over setM comp WellFormed toOptic mkLawful)
export Optics.Lens (get_put put_get put_put get_set set_get set_set)
export Optics.Lens (comp_preserves_laws lawful_wellFormed lawful_get_set lawful_set_get lawful_set_set)
