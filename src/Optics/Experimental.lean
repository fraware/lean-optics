/-
# Experimental tooling

Telemetry, performance monitoring, verification helpers, and container traversals.
Import explicitly when needed; not part of the stable public API.
-/

import Optics.Stdlib.Containers
import Optics.Telemetry.Core
import Optics.Telemetry.Timing
import Optics.Verification.Determinism
import Optics.Verification.Performance

export Optics (listTraverse listTraversal arrayTraversal optionTraversal sumTraversal)
export Optics.Telemetry (withTiming classifyGoal)
export Optics.Verification (testDeterminism testHypothesisOrderIndependence)
export Optics.Verification (runPerformanceBenchmark analyzePerformance)
