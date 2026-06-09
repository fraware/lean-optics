/-
# Record derivation helpers

`derive_lens` and `derive_lenses` generate lawful field lenses for structures.
-/

import Lean
import Lean.Elab.Command
import Optics.Concrete.Lens

namespace Optics

open Lean Elab Command

private def mkLawfulLensDecl (structName : Name) (fieldName : Name) : CommandElabM Syntax := do
  let env ← getEnv
  unless getStructureInfo? env structName |>.isSome do
    throwError "'{structName}' is not a structure"
  let proj := structName.append fieldName
  unless env.contains proj do
    throwError "field '{fieldName}' not found on structure '{structName}'"
  let lensName := Name.mkSimple (fieldName.toString ++ "Lens")
  let fieldIdent := mkIdentFrom (← getRef) fieldName
  let lensIdent := mkIdentFrom (← getRef) lensName
  let projIdent := mkIdentFrom (← getRef) proj
  `(def $lensIdent :=
    Lens.mkLawful $projIdent (fun s x => { s with $(fieldIdent):ident := x })
      (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl))

elab "derive_lens " structName:ident fieldName:ident : command => do
  let decl ← mkLawfulLensDecl structName.getId fieldName.getId
  elabCommand decl

elab "derive_lenses " structName:ident : command => do
  let s := structName.getId
  let env ← getEnv
  let some info := getStructureInfo? env s | throwError "'{s}' is not a structure"
  for field in info.fieldInfo do
    let decl ← mkLawfulLensDecl s field.fieldName
    elabCommand decl

end Optics
