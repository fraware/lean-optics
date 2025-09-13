# Quickstart Guide

This guide will get you started with lean-optics quickly.

## Basic Usage

### Creating Lenses

```lean
import Optics

-- Define a record
structure Person where
  name : String
  age : Nat
  email : String

-- Create a lens for the name field
def nameLens : Lens Person String :=
  lens! Person.name (fun p n => { p with name := n })

-- Use the lens
def updateName (p : Person) : Person :=
  nameLens.over (fun n => n.toUpper)
```

### Creating Prisms

```lean
-- Create a prism for Maybe
def maybePrism {A : Type} : Prism (Option A) A :=
  prism! (fun x => match x with | some a => Sum.inl a | none => Sum.inr none) some

-- Use the prism
def previewMaybe (x : Option String) : Option String :=
  maybePrism.preview x
```

### Creating Traversals

```lean
-- Create a traversal for List
def listTraversal {A : Type} : Traversal (List A) A :=
  traversal! (fun {F} [Applicative F] f xs =>
    match xs with
    | [] => pure []
    | x :: xs => do
      let y ← f x
      let ys ← listTraversal.traverse f xs
      pure (y :: ys))

-- Use the traversal
def incrementAll (xs : List Nat) : List Nat :=
  listTraversal.traverse (fun x => x + 1) xs
```

## Composition

### Lens Composition

```lean
-- Compose two lenses
def streetLens : Lens Address String :=
  lens! Address.street (fun a s => { a with street := s })

def addressLens : Lens Person Address :=
  lens! Person.address (fun p a => { p with address := a })

def streetLens' : Lens Person String :=
  streetLens ∘ₗ addressLens
```

### Mixed Composition

```lean
-- Compose a lens with a prism
def lensPrismComp : Lens S B :=
  lens_prism_comp lens prism

-- Compose a prism with a lens
def prismLensComp : Prism S B :=
  prism_lens_comp prism lens
```

## Using the optic_laws! Tactic

The `optic_laws!` tactic automatically discharges standard law obligations:

```lean
theorem nameLens_laws : Lens.WellFormed nameLens := by
  constructor
  · optic_laws!  -- Discharges get_put
  · optic_laws!  -- Discharges put_get
  · optic_laws!  -- Discharges put_put
```

## Record Derivation

Use the `derive_lens` macro to automatically create lenses for record fields:

```lean
structure Person where
  name : String
  age : Nat
  email : String
  deriving_lens name
  deriving_lens age
  deriving_lens email
```

## Container Traversals

Use the provided traversals for standard containers:

```lean
-- List traversal
def listTraversal {A : Type} : Traversal (List A) A :=
  listTraversal

-- Array traversal
def arrayTraversal {A : Type} : Traversal (Array A) A :=
  arrayTraversal

-- Option traversal
def optionTraversal {A : Type} : Traversal (Option A) A :=
  optionTraversal
```

## Troubleshooting

If `optic_laws!` fails to discharge a goal:

1. Enable tracing: `set_option trace.optics true`
2. Add custom simplification lemmas with `@[optic.simp]`
3. Check that your optic satisfies the required laws manually

## Next Steps

- Read the [API documentation](src/Optics/)
- Explore the [test suite](tests/)
- Check out the [benchmarks](bench/)
- Contribute to the project!
