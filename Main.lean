/-
# Lean Optics - Main Entry Point
-/

import Optics

def showHelp : IO Unit := do
  IO.println "Lean Optics - profunctor optics for Lean 4"
  IO.println "Version: 0.1.0"
  IO.println ""
  IO.println "USAGE:"
  IO.println "  lean-optics [COMMAND]"
  IO.println ""
  IO.println "COMMANDS:"
  IO.println "  help, -h, --help       Show this help message"
  IO.println "  version, -v, --version  Show version information"
  IO.println "  test                   Run the runtime test suite"
  IO.println "  bench, benchmark       Run performance benchmarks"
  IO.println "  example                Show usage examples"
  IO.println "  info                   Show library information"

def showVersion : IO Unit := do
  IO.println "Lean Optics v0.1.0"
  IO.println "Built with Lean 4.31.0"

def showInfo : IO Unit := do
  IO.println "Lean Optics - Library Information"
  IO.println "================================="
  IO.println ""
  IO.println "Stable:      import Optics"
  IO.println "Automation:  import Optics.Automation"
  IO.println "Experimental: import Optics.Experimental"
  IO.println ""
  IO.println "Modules:"
  IO.println "  Optics.Core       Profunctor, Strong, Choice, Traversing"
  IO.println "  Optics.Lens       Lens, LawfulLens, composition laws"
  IO.println "  Optics.Prism      Prism and well-formedness laws"
  IO.println "  Optics.Traversal  Traversal and composition"
  IO.println "  Optics.Compose    Cross-optic and law-preserving composition"

def showExample : IO Unit := do
  IO.println "Macro-free lawful lens:"
  IO.println "```lean"
  IO.println "import Optics"
  IO.println ""
  IO.println "structure Person where name : String; age : Nat"
  IO.println ""
  IO.println "def nameLens : LawfulLens Person String :="
  IO.println "  Lens.mkLawful Person.name (fun p n => { p with name := n })"
  IO.println "    (by intro _ _; rfl) (by intro _; rfl) (by intro _ _ _; rfl)"
  IO.println ""
  IO.println "def upper (p : Person) : Person := nameLens.over (fun n => n.toUpper) p"
  IO.println "```"

private def siblingExe (stem : String) : IO System.FilePath := do
  let self ← IO.appPath
  let dir ← match self.parent with
    | some dir => pure dir
    | none => throw (IO.userError "cannot resolve executable directory")
  let ext := self.extension.getD ""
  return if ext.isEmpty then dir / stem else dir / (stem ++ "." ++ ext)

def runTests : IO UInt32 := do
  IO.println "Running Lean Optics test suite..."
  let testRunner ← siblingExe "test-runner"
  unless ← testRunner.pathExists do
    IO.eprintln s!"Test runner not found at {testRunner}; run `lake build test-runner` first"
    return 1
  let proc ← IO.Process.spawn {
    cmd := testRunner.toString
    cwd := some (← IO.currentDir)
    stdout := .inherit
    stderr := .inherit
  }
  proc.wait

def runBenchmarks : IO UInt32 := do
  IO.println "Run benchmarks with: lake exe bench"
  return 0

def main (args : List String) : IO UInt32 := do
  match args with
  | [] => showHelp; return 0
  | [arg] =>
    match arg with
    | "help" | "-h" | "--help" => showHelp; return 0
    | "version" | "-v" | "--version" => showVersion; return 0
    | "info" => showInfo; return 0
    | "example" => showExample; return 0
    | "test" => runTests
    | "bench" | "benchmark" => runBenchmarks
    | _ =>
      IO.println s!"Unknown command: {arg}"
      IO.println "Run 'lean-optics help' for usage information"
      return 1
  | _ =>
    IO.println "Too many arguments"
    IO.println "Run 'lean-optics help' for usage information"
    return 1
