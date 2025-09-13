/-!
# Lean Optics - Main Entry Point

This is the main entry point for the lean-optics library.
-/

import Optics

def main : IO Unit := do
  IO.println "Lean Optics - Industrial-quality optics over profunctors"
  IO.println "Version: 1.0.0"
  IO.println ""
  IO.println "Available modules:"
  IO.println "- Optics.Core: Core profunctor classes"
  IO.println "- Optics.Concrete: Lens, Prism, Traversal structures"
  IO.println "- Optics.Compose: Composition operators"
  IO.println "- Optics.Tactics: optic_laws! tactic"
  IO.println "- Optics.Macros: lens!, prism!, traversal! macros"
  IO.println "- Optics.Stdlib: Record derivation and container traversals"
  IO.println ""
  IO.println "Run 'lake build' to build the library"
  IO.println "Run 'lake test' to run the test suite"
  IO.println "Run 'lake bench' to run the benchmarks"
