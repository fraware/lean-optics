/-!
# Lean Optics - Main Entry Point

This is the main entry point for the lean-optics library.
-/

import Optics

def showHelp : IO Unit := do
  IO.println "Lean Optics - Industrial-quality optics over profunctors"
  IO.println "Version: 1.0.0"
  IO.println ""
  IO.println "USAGE:"
  IO.println "  lean-optics [COMMAND] [OPTIONS]"
  IO.println ""
  IO.println "COMMANDS:"
  IO.println "  help, -h, --help     Show this help message"
  IO.println "  version, -v, --version  Show version information"
  IO.println "  test                 Run the test suite"
  IO.println "  bench                Run performance benchmarks"
  IO.println "  docs                 Generate documentation"
  IO.println "  example              Show usage examples"
  IO.println "  info                 Show library information"
  IO.println ""
  IO.println "QUICKSTART:"
  IO.println "  # Install and run tests"
  IO.println "  make dev && make test"
  IO.println ""
  IO.println "  # Run with Docker"
  IO.println "  docker run --rm ghcr.io/fraware/lean-optics:latest"
  IO.println ""
  IO.println "  # Add to your Lakefile.lean"
  IO.println "  require lean-optics from git \"https://github.com/fraware/lean-optics.git\" @ \"main\""

def showVersion : IO Unit := do
  IO.println "Lean Optics v1.0.0"
  IO.println "Built with Lean 4.8.0"

def showInfo : IO Unit := do
  IO.println "Lean Optics - Library Information"
  IO.println "================================="
  IO.println ""
  IO.println "Available modules:"
  IO.println "- Optics.Core: Core profunctor classes (Profunctor, Strong, Choice, Traversing)"
  IO.println "- Optics.Concrete: Lens, Prism, Traversal structures"
  IO.println "- Optics.Compose: Law-preserving composition operators"
  IO.println "- Optics.Tactics: optic_laws! tactic for automated proof generation"
  IO.println "- Optics.Macros: lens!, prism!, traversal! macros with law obligations"
  IO.println "- Optics.Stdlib: Record derivation and container traversals"
  IO.println "- Optics.Telemetry: Performance monitoring and timing"
  IO.println "- Optics.Verification: Determinism and performance verification"
  IO.println ""
  IO.println "Performance targets:"
  IO.println "- P95 ≤ 200ms per optic_laws! tactic"
  IO.println "- P50 ≤ 80ms median completion"
  IO.println "- Deterministic proof terms across runs"
  IO.println "- Byte-stable proof terms"

def showExample : IO Unit := do
  IO.println "Lean Optics - Usage Examples"
  IO.println "============================"
  IO.println ""
  IO.println "1. Basic Lens Usage:"
  IO.println "```lean"
  IO.println "import Optics"
  IO.println ""
  IO.println "structure Person where"
  IO.println "  name : String"
  IO.println "  age : Nat"
  IO.println ""
  IO.println "def nameLens : Lens Person String :="
  IO.println "  lens! Person.name (fun p n => { p with name := n })"
  IO.println ""
  IO.println "def updateName (p : Person) : Person :="
  IO.println "  nameLens.over (fun n => n.toUpper)"
  IO.println "```"
  IO.println ""
  IO.println "2. Prism for Optional Values:"
  IO.println "```lean"
  IO.println "def maybePrism : Prism (Option String) String :="
  IO.println "  prism! (fun x => match x with | some s => Sum.inl s | none => Sum.inr none) some"
  IO.println "```"
  IO.println ""
  IO.println "3. Composition:"
  IO.println "```lean"
  IO.println "def streetLens' : Lens Person String :="
  IO.println "  streetLens ∘ₗ addressLens"
  IO.println "```"

def runTests : IO Unit := do
  IO.println "Running Lean Optics test suite..."
  IO.println "This will execute the comprehensive test runner."
  IO.println "For detailed output, run: lake exe test-runner"

def runBenchmarks : IO Unit := do
  IO.println "Running Lean Optics benchmarks..."
  IO.println "This will execute performance benchmarks."
  IO.println "For detailed output, run: lake exe bench"

def generateDocs : IO Unit := do
  IO.println "Generating documentation..."
  IO.println "This will build the documentation."
  IO.println "For detailed output, run: lake build docs"

def main (args : List String) : IO Unit := do
  match args with
  | [] => showHelp
  | [arg] =>
    match arg with
    | "help" | "-h" | "--help" => showHelp
    | "version" | "-v" | "--version" => showVersion
    | "info" => showInfo
    | "example" => showExample
    | "test" => runTests
    | "bench" | "benchmark" => runBenchmarks
    | "docs" => generateDocs
    | _ => do
      IO.println s!"Unknown command: {arg}"
      IO.println "Run 'lean-optics help' for usage information"
  | _ => do
    IO.println "Too many arguments"
    IO.println "Run 'lean-optics help' for usage information"
