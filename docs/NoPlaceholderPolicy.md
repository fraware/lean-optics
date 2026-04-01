# No Placeholder and Safety Policy

This repository enforces a strict no-placeholder standard for production quality.

## Prohibited Patterns

- `sorry` and `admit` in Lean code.
- Partial parsing in runtime code (for example `String.toNat!` on untrusted input).
- Stub markers such as "Would send to webhook" and "In a real implementation".
- Placeholder-proof comments in files that are built or tested in CI.

## Required Practices

- Use total parsing with explicit defaults and validation for env/config input.
- Prefer deterministic outputs for checks, tests, and telemetry fields.
- Make benchmark and determinism checks machine-verifiable in CI.
- Keep dependencies pinned to immutable revisions.

## CI Enforcement

- `scripts/ci/check_placeholders.sh` blocks prohibited patterns.
- `scripts/ci/check_determinism.sh` validates stable normalized test output.
- Security and SBOM jobs run on every push and release pipeline.
