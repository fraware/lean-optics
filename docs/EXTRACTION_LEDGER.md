# Extraction ledger

Tracks upstream extraction candidates from `lean-optics` toward CSLib and Mathlib.

## Ready for discussion

| Item | Module | Status |
|------|--------|--------|
| Minimal lawful `Lens` / `LawfulLens` | `Optics.Concrete.Lens`, `Optics.Lens` | Ready |
| `Lens.over` API | `Optics.Lens` | Ready |
| Lens composition (`∘ₗ`, `lens_comp_preserves_laws`) | `Optics.Compose` | Ready |
| State-record update example (no macros) | `Optics.Examples.LawfulLens` | Ready |
| Machine interpreter state example | `Optics.Examples.MachineState` | Ready |
| CSLib upstream proposal | `docs/upstream/CSLIB_LENS_PROPOSAL.md` | Draft PR [cslib#659](https://github.com/leanprover/cslib/pull/659), discussion [cslib#658](https://github.com/leanprover/cslib/issues/658) |
| Macro-free test fixtures | `tests.Common` | Ready |
| `derive_lens` / `derive_lenses` | `Optics.Stdlib.Records` | Ready |
| `Lens.of` / `Prism.of` / `Traversal.of` | concrete modules | Ready |

## Postponed

| Item | Reason |
|------|--------|
| Prism core | Lens layer must stabilize first |
| Traversal core | Lens layer must stabilize first |
| Profunctor abstraction | CSLib conversation is example-driven; Mathlib audit pending |

## Import layers

| Layer | Module | Purpose |
|-------|--------|---------|
| Stable API | `Optics` | Core, lens, prism, traversal, compose |
| Automation | `Optics.Automation` | Macros, tactics, record helpers |
| Experimental | `Optics.Experimental` | Telemetry, verification, container traversals |

## Toolchain

- Lean: `v4.31.0`
- Batteries: `v4.31.0` (dependency retained; not required by stable API)
- Lake config: `lakefile.toml` (Lake 5 / Lean 4.31 declarative format)

## Verification commands

```bash
lake update
lake build
lake build tests
lake exe test-runner
lake exe test-advanced
lake exe bench
```

The core test suite uses explicit optic constructors (no macros). Runtime tests live
in `tests.Runner`; proof-level checks are in `tests.*.Basic` and `tests.Integration`.
Advanced golden fixtures (`tests.Advanced.*`) exercise macros and deep composition.
