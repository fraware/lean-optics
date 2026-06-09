<div align="center">

# lean-optics

`lean-optics` is a Lean 4 package that implements profunctor-style optics:
`Lens`, `Prism`, `Traversal`, plus law-preserving composition.

[![Lean 4](https://img.shields.io/badge/Lean%204-v4.31.0--rc1-blue.svg)](https://leanprover.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

</div>

## Install and import

Add this dependency to your `lakefile.toml`:

```toml
[[require]]
name = "lean-optics"
git = "https://github.com/fraware/lean-optics.git"
rev = "main"
```

Stable API (no macros):

```lean
import Optics
```

Automation (macros, `derive_lens`, tactics):

```lean
import Optics.Automation
```

## Minimal example (macro-free)

```lean
import Optics

structure Person where
  name : String
  age : Nat

def nameLens : LawfulLens Person String :=
  Lens.mkLawful
    (get := Person.name)
    (set := fun p n => { p with name := n })
    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)

def renamed : Person :=
  nameLens.over (fun n => n.toUpper) { name := "Alice", age := 30 }
```

See `Optics.Examples.LawfulLens` for a complete upstream extraction example.

## Build and verify

```bash
lake update
lake build
lake build tests testsAdvanced
lake exe test-runner
lake exe test-advanced
lake exe bench
```

## Module layers

| Layer | Import | Contents |
|-------|--------|----------|
| Stable | `Optics` | Core, lawful lens, prism, traversal, compose |
| Automation | `Optics.Automation` | `lens!`, `prism!`, `derive_lens`, tactics |
| Experimental | `Optics.Experimental` | Container traversals, telemetry, verification |

## License

MIT. See [LICENSE](LICENSE).
