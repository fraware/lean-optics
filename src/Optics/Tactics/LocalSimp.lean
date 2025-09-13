/-!
# Local Simplification Kernel

This module provides a small, focused simplification kernel for the optic_laws! tactic.
-/

import Lean

namespace Optics

/-- Attribute for marking lemmas usable by the optic_laws! tactic. -/
register_simp_attr optic.law

/-- Attribute for registering canonical simplification lemmas. -/
register_simp_attr optic.simp

/-- Local simplification set for optic laws. -/
def opticSimpSet : Lean.SimpSet := by
  simpset% [optic.law, optic.simp, Function.comp_apply, funext_iff, Prod.mk.eta]

/-- Register a lemma for use by the optic_laws! tactic. -/
syntax (name := optic_law_attr) "optic.law" : attr

initialize opticLawAttr : Lean.TagAttribute ←
  Lean.registerTagAttribute `optic.law "lemma usable by optic_laws! tactic"

/-- Register a simplification lemma. -/
syntax (name := optic_simp_attr) "optic.simp" : attr

initialize opticSimpAttr : Lean.TagAttribute ←
  Lean.registerTagAttribute `optic.simp "simplification lemma for optic_laws! tactic"

/-- Register basic lemmas for the optic_laws! tactic. -/

@[optic.law]
theorem Function.comp_id {α β : Type*} (f : α → β) : f ∘ id = f := rfl

@[optic.law]
theorem Function.id_comp {α β : Type*} (f : α → β) : id ∘ f = f := rfl

@[optic.simp]
theorem Prod.mk_eta {α β : Type*} (p : α × β) : (p.1, p.2) = p := by cases p; rfl

@[optic.simp]
theorem funext_iff {α β : Type*} {f g : α → β} : f = g ↔ ∀ x, f x = g x := Function.funext_iff

end Optics
