import Lake
open Lake DSL

package «lean-optics» where
  -- Build configuration for Lean/Lake v4.8.0 lives here.

require batteries from git
  "https://github.com/leanprover-community/batteries" @ "36752f7c96ae43bdb4d00d0a7aafb4ca8ac06064"

@[default_target]
lean_lib «Optics» where
  srcDir := "src"

lean_exe «lean-optics» where
  root := `Main

-- Test targets
lean_exe «test-lens» where
  root := `tests.Lens.Main

lean_exe «test-prism» where
  root := `tests.Prism.Main

lean_exe «test-traversal» where
  root := `tests.Traversal.Main

lean_exe «test-compose» where
  root := `tests.Compose.Main

lean_exe «test-runner» where
  root := `tests.TestRunner

-- Benchmark targets
lean_exe «bench» where
  root := `bench.Bench
