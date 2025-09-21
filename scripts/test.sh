#!/bin/bash

# Lean Optics - Comprehensive Test Script
# =======================================

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Lean Optics Test Suite${NC}"
echo "========================"
echo ""

# Function to run a test and report results
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ $test_name passed${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_name failed${NC}"
        return 1
    fi
}

# Track test results
total_tests=0
passed_tests=0
failed_tests=0

# Test 1: Basic compilation
run_test "Basic Compilation" "lake build"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 2: Run main executable
run_test "Main Executable" "lake exe lean-optics help"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 3: Version check
run_test "Version Check" "lake exe lean-optics version"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 4: Test runner
run_test "Test Runner" "lake exe test-runner"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 5: Individual test modules
run_test "Lens Tests" "lake exe test-lens"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

run_test "Prism Tests" "lake exe test-prism"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

run_test "Traversal Tests" "lake exe test-traversal"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

run_test "Composition Tests" "lake exe test-compose"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Test 6: Benchmarks (if available)
if lake exe bench >/dev/null 2>&1; then
    run_test "Benchmarks" "lake exe bench"
    if [ $? -eq 0 ]; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
fi

# Test 7: Documentation generation
run_test "Documentation" "lake build docs"
if [ $? -eq 0 ]; then
    ((passed_tests++))
else
    ((failed_tests++))
fi
((total_tests++))

# Report results
echo ""
echo "=========================================="
echo -e "${GREEN}TEST SUITE RESULTS${NC}"
echo "=========================================="
echo "Total Tests: $total_tests"
echo -e "Passed: ${GREEN}$passed_tests${NC}"
echo -e "Failed: ${RED}$failed_tests${NC}"

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${RED}❌ SOME TESTS FAILED${NC}"
    exit 1
fi
