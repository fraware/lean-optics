@echo off
setlocal enabledelayedexpansion

REM Lean Optics - Comprehensive Test Script for Windows
REM ===================================================

echo Lean Optics Test Suite
echo ========================
echo.

REM Track test results
set total_tests=0
set passed_tests=0
set failed_tests=0

REM Function to run a test and report results
:run_test
set test_name=%~1
set test_command=%~2

echo Running: %test_name%
%test_command%
if %errorlevel% equ 0 (
    echo [OK] %test_name% passed
    set /a passed_tests+=1
) else (
    echo [FAIL] %test_name% failed
    set /a failed_tests+=1
)
set /a total_tests+=1
goto :eof

REM Test 1: Basic compilation
call :run_test "Basic Compilation" "lake build"

REM Test 2: Run main executable
call :run_test "Main Executable" "lake exe lean-optics help"

REM Test 3: Version check
call :run_test "Version Check" "lake exe lean-optics version"

REM Test 4: Test runner
call :run_test "Test Runner" "lake exe test-runner"

REM Test 5: Individual test modules
call :run_test "Lens Tests" "lake exe test-lens"
call :run_test "Prism Tests" "lake exe test-prism"
call :run_test "Traversal Tests" "lake exe test-traversal"
call :run_test "Composition Tests" "lake exe test-compose"

REM Test 6: Benchmarks (if available)
lake exe bench >nul 2>&1
if %errorlevel% equ 0 (
    call :run_test "Benchmarks" "lake exe bench"
)

REM Test 7: Documentation generation
call :run_test "Documentation" "lake build docs"

REM Report results
echo.
echo ==========================================
echo TEST SUITE RESULTS
echo ==========================================
echo Total Tests: %total_tests%
echo Passed: %passed_tests%
echo Failed: %failed_tests%

if %failed_tests% equ 0 (
    echo [SUCCESS] ALL TESTS PASSED!
    exit /b 0
) else (
    echo [FAILURE] SOME TESTS FAILED
    exit /b 1
)
