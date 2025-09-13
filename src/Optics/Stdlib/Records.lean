/-!
# Record Derivation Helpers

This module provides helpers for automatically deriving lenses for record fields.
-/

import Lean
import Optics.Concrete.Lens

namespace Optics

/-- Derive a lens for a record field. -/
macro "derive_lens " structName:ident " " fieldName:ident : command => do
  let lensName := fieldName.getId ++ "lens"
  let structNameStr := structName.getId.toString
  let fieldNameStr := fieldName.getId.toString

  `(def $(mkIdent lensName) : Lens $(mkIdent structName.getId) _ :=
      lens! $(mkIdent fieldName.getId) (fun s a => { s with $(mkIdent fieldName.getId) := a }))

/-- Derive lenses for all fields of a record. -/
elab "derive_lenses " structName:ident : command => do
  let structNameId := structName.getId

  -- Get structure information from environment
  let env ← Lean.getEnv
  let structInfo? := Lean.getStructureInfo? env structNameId

  match structInfo? with
  | some structInfo => do
    -- Generate lens definition for each field using syntax generation
    let mut commands : Array Lean.Syntax := #[]

    for fieldName in structInfo.fieldNames do
      let lensName := fieldName ++ "lens"
      let fieldNameStr := fieldName.toString

      -- Generate the lens definition using syntax
      let lensDef :=
        `(def $(mkIdent lensName) : Lens $(mkIdent structNameId) _ :=
            lens! $(mkIdent fieldName) (fun s a => { s with $(mkIdent fieldName) := a }))

      commands := commands.push lensDef

    -- Return all generated commands
    Lean.mkNullNode commands

  | none =>
    Lean.throwError s!"Structure {structNameId} not found in environment"

/-- Derive lenses for all fields of a record (alternative syntax). -/
macro "derive_lenses" : command => do
  Lean.throwError "derive_lenses requires a structure name - use 'derive_lenses MyStruct'"

end Optics
