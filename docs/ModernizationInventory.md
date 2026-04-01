# Modernization Inventory and Remediation Map

This document is the frozen baseline for placeholder/stub removal and modernization.

## Runtime and Verification

- `src/Optics/Telemetry/Core.lean`
  - Unsafe partial env parsing via `String.toNat!`.
  - Webhook output path was a non-delivering stub.
  - Remediation: total parsing with defaults, plus best-effort JSON webhook delivery with explicit error reporting.

- `src/Optics/Telemetry/Timing.lean`
  - Mathlib version reporting returned a placeholder value.
  - Remediation: detect version from `lake-manifest.json` when available, with explicit fallback sentinel.

- `src/Optics/Verification/Determinism.lean`
  - Hashing used raw `toString` with stub comments.
  - Hypothesis-order check contained non-implemented path commentary.
  - Remediation: stable expression normalization and hash-based comparison, deterministic repeated-run checks without stub markers.

- `src/Optics/Verification/Performance.lean`
  - Memory threshold marker documented as placeholder.
  - Continuous monitoring entrypoint was a no-op.
  - Remediation: configurable memory threshold and real monitoring loop with periodic checkpoints and SLA evaluation output.

## Tests and Docs

- `tests/Advanced/RefactorSemantics.lean`
- `tests/Advanced/NestedRecords.lean`
- `tests/Advanced/ComplexPrismComposition.lean`
  - Placeholder proof comments and `sorry`.
  - Remediation: remove placeholders; keep files as explicit non-gating scenario fixtures while eliminating stub proofs.

- `docs/FailureGuide.md`
  - Example used `by sorry`.
  - Remediation: replace with complete, non-placeholder example proof.

## Reproducibility and CI

- `Lakefile.lean`
  - Dependency pinned to mutable branch `main`.
  - Remediation: pin dependency to immutable commit SHA.

- `.github/workflows/ci.yml`
  - Cache key used wrong file casing.
  - Missing anti-placeholder gate, determinism gate, security scanning, and SBOM.
  - Remediation: enforce strict CI checks and security/supply-chain jobs.
