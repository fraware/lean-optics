/-!
# Macros for Creating Optics with Law Obligations

This module provides macros for creating lenses, prisms, and traversals
that automatically generate law subgoals as obligations.
-/

import Lean
import Optics.Concrete.Lens
import Optics.Concrete.Prism
import Optics.Concrete.Traversal

namespace Optics

/-- Macro for creating a lens with law obligations. -/
macro "lens! " get:term " " set:term : term => do
  let lens := Lean.mkApp (Lean.mkConst ``Lens.mk) #[get, set]
  let getPutGoal := Lean.mkApp (Lean.mkConst ``Lens.get_put) #[lens]
  let putGetGoal := Lean.mkApp (Lean.mkConst ``Lens.put_get) #[lens]
  let putPutGoal := Lean.mkApp (Lean.mkConst ``Lens.put_put) #[lens]

  Lean.mkAppM ``have #[getPutGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]],
    Lean.mkAppM ``have #[putGetGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]],
      Lean.mkAppM ``have #[putPutGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]], lens]]]

/-- Macro for creating a prism with law obligations. -/
macro "prism! " match:term " " build:term : term => do
  let prism := Lean.mkApp (Lean.mkConst ``Prism.mk) #[match, build]
  let matchBuildGoal := Lean.mkApp (Lean.mkConst ``Prism.match_build) #[prism]
  let buildMatchGoal := Lean.mkApp (Lean.mkConst ``Prism.build_match) #[prism]
  let noMatchIdGoal := Lean.mkApp (Lean.mkConst ``Prism.no_match_id) #[prism]

  Lean.mkAppM ``have #[matchBuildGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]],
    Lean.mkAppM ``have #[buildMatchGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]],
      Lean.mkAppM ``have #[noMatchIdGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]], prism]]]

/-- Macro for creating a traversal with law obligations. -/
macro "traversal! " traverse:term : term => do
  let traversal := Lean.mkApp (Lean.mkConst ``Traversal.mk) #[traverse]
  let identityGoal := Lean.mkApp (Lean.mkConst ``Traversal.identity_law) #[traversal]
  let compositionGoal := Lean.mkApp (Lean.mkConst ``Traversal.composition_law) #[traversal]
  let naturalityGoal := Lean.mkApp (Lean.mkConst ``Traversal.naturality_law) #[traversal]

  Lean.mkAppM ``have #[identityGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]],
    Lean.mkAppM ``have #[compositionGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]],
      Lean.mkAppM ``have #[naturalityGoal, Lean.mkAppM ``by #[Lean.mkAppM ``optic_laws! #[]], traversal]]]

end Optics
