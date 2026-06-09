#!/usr/bin/env bash
# Lean Optics - comprehensive test script

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

total_tests=0
passed_tests=0
failed_tests=0

run_test() {
  local test_name="$1"
  local test_command="$2"
  echo -e "${YELLOW}Running: ${test_name}${NC}"
  if eval "${test_command}"; then
    echo -e "${GREEN}OK ${test_name}${NC}"
    passed_tests=$((passed_tests + 1))
  else
    echo -e "${RED}FAIL ${test_name}${NC}"
    failed_tests=$((failed_tests + 1))
  fi
  total_tests=$((total_tests + 1))
}

run_test "Library build" "lake build"
run_test "Test libraries" "lake build tests testsAdvanced"
run_test "CLI help" "lake exe lean-optics help"
run_test "CLI version" "lake exe lean-optics version"
run_test "Test runner" "lake exe test-runner"
run_test "Advanced tests" "lake exe test-advanced"
run_test "Lens tests" "lake exe test-lens"
run_test "Prism tests" "lake exe test-prism"
run_test "Traversal tests" "lake exe test-traversal"
run_test "Compose tests" "lake exe test-compose"
run_test "Benchmarks" "lake exe bench"
run_test "CLI test command" "lake exe lean-optics test"

echo ""
echo "=========================================="
echo -e "${GREEN}TEST SUITE RESULTS${NC}"
echo "=========================================="
echo "Total: ${total_tests}  Passed: ${passed_tests}  Failed: ${failed_tests}"

if [ "${failed_tests}" -eq 0 ]; then
  echo -e "${GREEN}ALL TESTS PASSED${NC}"
  exit 0
else
  echo -e "${RED}SOME TESTS FAILED${NC}"
  exit 1
fi
