import Lake
open Lake DSL

package «lean-optics» where
  -- add package configuration options here

require batteries from git
  "https://github.com/leanprover-community/batteries" @ "main"

@[default_target]
lean_lib «Optics» where
  -- add library configuration options here

lean_exe «lean-optics» where
  root := `Main

-- Test targets
lean_exe «test-lens» where
  root := `Tests.Lens.Main

lean_exe «test-prism» where
  root := `Tests.Prism.Main

lean_exe «test-traversal» where
  root := `Tests.Traversal.Main

lean_exe «test-compose» where
  root := `Tests.Compose.Main

lean_exe «test-runner» where
  root := `Tests.TestRunner

-- Benchmark targets
lean_exe «bench» where
  root := `Bench.Main
