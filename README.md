# lean-optics

`lean-optics` is a Lean 4 package that implements profunctor-style optics:
`Lens`, `Prism`, `Traversal`, plus composition helpers.

[![Lean 4](https://img.shields.io/badge/Lean%204-v4.8.0-blue.svg)](https://leanprover.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## Install and import

Add this dependency to your `Lakefile.lean`:

```lean
require lean-optics from git
  "https://github.com/fraware/lean-optics.git" @ "<tag-or-commit>"
```

Import path:

```lean
import Optics
```

## Minimal example

```lean
import Optics

structure Person where
  name : String
  age : Nat

def nameLens : Lens Person String :=
  lens! Person.name (fun p n => { p with name := n })

def renamed : Person :=
  nameLens.set { name := "Alice", age := 30 } "Bob"
```

## Build from repo root

```bash
lake build
```

## Notes

- This repository is under active development.
- Some advanced helper commands are intentionally not implemented yet.

## License

MIT. See [LICENSE](LICENSE).
