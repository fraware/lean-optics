@echo off
setlocal enabledelayedexpansion

echo Lean Optics Test Suite
echo ========================
echo.

set total_tests=0
set passed_tests=0
set failed_tests=0

goto :main

:run_test
set test_name=%~1
set test_command=%~2
echo Running: %test_name%
%test_command%
if %errorlevel% equ 0 (
    echo [OK] %test_name%
    set /a passed_tests+=1
) else (
    echo [FAIL] %test_name%
    set /a failed_tests+=1
)
set /a total_tests+=1
exit /b 0

:main
call :run_test "Library build" "lake build"
call :run_test "Test libraries" "lake build tests testsAdvanced"
call :run_test "CLI help" "lake exe lean-optics help"
call :run_test "CLI version" "lake exe lean-optics version"
call :run_test "Test runner" "lake exe test-runner"
call :run_test "Advanced tests" "lake exe test-advanced"
call :run_test "Lens tests" "lake exe test-lens"
call :run_test "Prism tests" "lake exe test-prism"
call :run_test "Traversal tests" "lake exe test-traversal"
call :run_test "Compose tests" "lake exe test-compose"
call :run_test "Benchmarks" "lake exe bench"
call :run_test "CLI test command" "lake exe lean-optics test"

echo.
echo ==========================================
echo TEST SUITE RESULTS
echo ==========================================
echo Total Tests: %total_tests%
echo Passed: %passed_tests%
echo Failed: %failed_tests%

if %failed_tests% equ 0 (
    echo [SUCCESS] ALL TESTS PASSED
    exit /b 0
) else (
    echo [FAILURE] SOME TESTS FAILED
    exit /b 1
)
