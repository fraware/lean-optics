# Modernization and extraction sprint

This document records the first modernization and extraction plan for `lean-optics` as part of the broader category-theory contribution program targeting Mathlib and CSLib.

## Current repository position

`lean-optics` implements profunctor-style optics, including lenses, prisms, traversals, composition helpers, macros, tactics, record helpers, container traversals, telemetry, and verification modules.

The top-level import currently exposes several layers at once: core profunctor classes, concrete optics, composition, tactics, macros, stdlib helpers, telemetry, and verification. That is useful for a demo package, but too broad for upstream extraction.

Current constraints:

- Current toolchain in `lean-toolchain`: `leanprover/lean4:v4.8.0`.
- The package depends on Batteries, not Mathlib, through a pinned commit in `Lakefile.lean`.
- The README notes that some advanced helper commands are intentionally not implemented yet.
- The top-level module imports automation, telemetry, and verification together with the core optics API.

## Sprint objective

The objective is to split the repository into an upstreamable core and a separate experimental/tooling layer.

The first upstream target should be CSLib-facing. Mathlib extraction should wait until the core laws, naming, and categorical framing are stable enough to justify a general-purpose mathematical API.

## Modernization gates

### Gate 1: Lean 4.31 compatibility without changing the public API

Run the current package on the Lean 4.31 line, preserving the existing import surface.

Required commands:

```bash
lake update
lake build
lake exe test-runner
```

Expected first failures to check:

- Lake syntax changes from Lean 4.8 to Lean 4.31.
- Batteries API drift.
- Macro elaborator changes affecting `lens!`, `prism!`, and `traversal!`.
- Tactic elaboration changes affecting `optic_laws!`.

### Gate 2: split the import surface

Create explicit import layers.

Recommended target layout:

```text
src/Optics/Core.lean              -- profunctor classes only
src/Optics/Lens.lean              -- lawful lens structure and API
src/Optics/Prism.lean             -- lawful prism structure and API
src/Optics/Traversal.lean         -- traversal structure and API
src/Optics/Compose.lean           -- composition lemmas
src/Optics/Automation.lean        -- tactics and macros
src/Optics/Experimental.lean      -- telemetry, verification, benchmarks
src/Optics.lean                   -- stable public import only
```

The stable public import should not import telemetry or performance benchmarks.

### Gate 3: establish law surfaces

Each concrete optic should have a small, named law API that works without automation.

For lenses, the upstreamable minimum is:

- `get_set`;
- `set_get`;
- `set_set`;
- `over` definitions and basic simp lemmas;
- composition preserving lens laws.

For prisms and traversals, postpone upstream extraction until the lens layer is robust.

## Extraction targets

### Target A: CSLib verified state access

The first CSLib-facing contribution should use lenses for verified record or state transformations.

Candidate contribution:

- a minimal lawful `Lens` structure;
- examples over simple state records;
- composition lemmas;
- no macros;
- no profunctor encoding in the first PR unless maintainers request it.

### Target B: Mathlib-facing profunctor audit

Before any Mathlib PR, check whether Mathlib already has abstractions for profunctors, bifunctors, or related categorical structures. If not, do not introduce a large optics framework first. Introduce only the smallest reusable definitions or examples.

### Target C: internal extraction from tactics

Use `optic_laws!` as a friction detector. Each law proof that automation discharges repeatedly should be inspected for a missing simp lemma, extensionality lemma, or small API theorem. Upstream those lemmas before upstreaming the tactic.

## Non-upstream material for now

The following should remain repository-local during this sprint:

- `lens!`, `prism!`, and `traversal!` macros;
- `optic_laws!` tactic;
- telemetry and timing modules;
- performance benchmark modules;
- verification modules that test determinism and hypothesis-order independence;
- broad profunctor optics infrastructure beyond the minimal lawful API.

## First PR candidates generated from this repo

1. Local modernization PR: port to Lean 4.31 and refresh Batteries dependency.
2. Local architecture PR: split the top-level import into stable, automation, and experimental layers.
3. Local API PR: expose a small lawful `Lens` API without macros.
4. CSLib candidate PR: examples for state-field access and lawful state updates.
5. Mathlib candidate PR: only after a separate audit of existing profunctor or category-theory infrastructure.

## Build certification status

This document is a planning and extraction artifact. It does not certify that the repository has been built on Lean 4.31 yet. Certification requires a successful local or CI run of the commands in Gate 1.
