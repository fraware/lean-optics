# CSLib lens proposal

## Problem

Verified computer-science developments often need structured state updates over records. When modeling interpreters, simulators, or incremental transformations, authors repeatedly write the same pattern: read a field from a state record, compute an updated value, and write it back while preserving unrelated fields. Without a shared abstraction, each project reimplements getters, setters, and the algebraic laws that make those updates composable and trustworthy.

## Minimal contribution

A lawful lens API with `get`, `set`, `get_set`, `set_get`, `set_set`, `over`, and composition.

The API should be small enough to review in one sitting and strong enough to support verified state access:

- `get : S → A` extracts the focused component from whole state `S`.
- `set : S → A → S` replaces that component while leaving the rest of the record intact.
- `get_set`, `set_get`, and `set_set` are the standard lens laws, stated in `get`/`set` vocabulary.
- `over` applies a function to the focused component without naming the intermediate value.
- Composition chains nested field access (for example, state → memory cell → value).

This is the same core carried in this repository by `Optics.Concrete.Lens` and `Optics.Examples.LawfulLens`: a proof-free `Lens` for construction, a `LawfulLens` bundle for verification, `Lens.over`, and `Lens.comp` (written `∘ₗ`).

## Why CSLib

CSLib is the right first upstream venue because it supports executable state semantics and verified transformations without importing tactic automation. A minimal lens module fits CSLib’s role as foundational infrastructure for formalized algorithms and systems code: small types, explicit laws, and proof obligations that users discharge directly.

This repository’s profunctor optics, macros, `optic_laws!`, telemetry, and benchmarks are intentionally out of scope for that first contribution. They solve ergonomics and research problems; CSLib needs the lawful data-access core first.

## Out of scope

- Macros (`lens!`, field-syntax sugar)
- Profunctor hierarchy and optic generalizations
- Prisms, traversals, and other optic variants
- `optic_laws!` and other tactic automation
- Telemetry and performance monitoring
- Benchmarks

## CSLib next step

Open a CSLib discussion issue or draft PR with a minimal lawful lens API and one example.

The first candidate PR should include only:

```lean
structure Lens (S A : Type u) where
  get : S → A
  set : S → A → S

structure LawfulLens (S A : Type u) extends Lens S A where
  get_set : ∀ s a, get (set s a) = a
  set_get : ∀ s, set s (get s) = s
  set_set : ∀ s a b, set (set s a) b = set s b

def over (l : Lens S A) (f : A → A) : S → S :=
  fun s => l.set s (f (l.get s))

def compose (l₁ : Lens S A) (l₂ : Lens A B) : Lens S B :=
  ⟨l₂.get ∘ l₁.get, fun s b => l₁.set s (l₂.set (l₁.get s) b)⟩
```

Then include examples over simple record state:

```lean
structure MachineState where
  pc : Nat
  memory : List Nat
  halted : Bool
```

For instance, a lawful lens for `pc` and an `over` that increments the program counter while leaving `memory` and `halted` unchanged. The `Person` record example in `Optics.Examples.LawfulLens` in this repository shows the same proof pattern: field projection, `with` update, and `rfl` for each law.

Frame the contribution as **state access infrastructure**, not category theory — aligned with CSLib maintainer expectations. The goal is dependable record update for verified CS code, not a general optics library.

## Mathlib next step

No Mathlib PR yet. After CSLib maintainers accept or reject the state-access framing, revisit whether profunctor abstractions belong in Mathlib. For now, Mathlib is the wrong first venue: it optimizes for mathematical structure and broad reuse across analysis and algebra, while the immediate need is a tiny, law-carrying API for executable state.

If CSLib accepts the minimal lens core, this repository can continue to host profunctor optics, composition syntax, and automation as a downstream consumer rather than as upstream infrastructure.
