# lean-optics current-upstream audit — 2026-08-24

This document supersedes the June 2026 extraction ledger **for current upstream decisions**. The older ledger remains a historical record of the 4.31 modernization/extraction sprint.

## Audit baseline

- Lean: `leanprover/lean4:v4.34.0-rc2`
- Batteries: `d54dddc581e08be364c278052863524bff7a99a9` (main, toolchain bump to 4.34.0-rc2)
- Build status on this baseline: **pending CI** until the audit branch workflow completes successfully.

The repository's previous 4.31 build record is not a current-build claim.

## Current upstream state

The lawful-lens proposal is represented by:

- CSLib issue #658: `Proposal: lawful lenses for verified state access`
- CSLib draft PR #659: `feat(Foundations/Data): lawful lenses for verified state access`

As of this audit, #659 remains open and draft. No maintainer review comment has established acceptance of the abstraction.

The draft PR has been narrowed from the original version:

- the core `Lens` / `LawfulLens` API is universe-polymorphic;
- premature custom composition notation was removed;
- constructor/wrapper declarations duplicating structure construction or law fields were removed;
- the synthetic `MachineState` production example was removed;
- usage evidence was moved to a test over CSLib's existing `URM.State`;
- the root `Cslib` import exposes the core module, not an example module.

## Candidate decision

### Minimal lawful lens core

Potential value: **high relative to the current portfolio**.
Current status: **active draft candidate**.
Upstream certainty: **not established**.

The candidate remains plausible because current CSLib does not expose an equivalent lawful getter/setter abstraction in the audit searches, while verified state-manipulation developments have concrete uses for focused update laws.

That finding is an audit result, not proof that maintainers want the abstraction. The PR should remain draft until CI is green and the contributor is ready to defend the API design.

## Public-surface discipline

The first upstream slice should remain limited to:

- `Lens`;
- `LawfulLens` and the three standard laws;
- `Lens.over`;
- nested composition;
- proof that lawful lenses compose;
- focused tests demonstrating use on existing CSLib structures.

Explicitly deferred:

- prism core;
- traversal core;
- profunctor optics;
- derivation macros;
- tactics;
- telemetry/benchmarks;
- repository-specific automation.

## Design questions still open

The draft intentionally does not pretend these questions are settled:

1. whether CSLib prefers law proofs bundled in `LawfulLens` or a separate proposition about a `Lens`;
2. naming and namespace conventions for composition;
3. whether the abstraction belongs under `Foundations/Data` or another current CSLib location;
4. whether one concrete CSLib consumer is sufficient evidence, or maintainers want additional downstream use before accepting a foundational primitive.

These should be resolved through maintainer feedback, not by expanding the local abstraction speculatively.

## Evidence standard before marking #659 ready

1. Current upstream CI passes.
2. `lake test` and `lake exe checkInitImports` pass in the CSLib PR workspace.
3. Import/lint checks required by CSLib pass.
4. The contributor personally understands and can explain each declaration and proof.
5. AI assistance remains accurately disclosed.
6. No prisms/traversals/profunctor machinery is added to make the lens core appear more substantial.
7. The PR remains useful even if `lean-optics` itself did not exist.

## Local repository role after extraction

`lean-optics` should remain the experimental environment for:

- richer optic families;
- composition ergonomics;
- record derivation;
- automation;
- stress tests and examples.

An accepted CSLib lens core, if it occurs, should become a dependency/reference point for future extraction rather than a reason to copy the entire local optics hierarchy upstream.
