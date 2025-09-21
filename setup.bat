@echo off
setlocal enabledelayedexpansion

REM Lean Optics - Windows Setup Script
REM ==================================

echo Lean Optics Setup
echo =================
echo.

REM Check if Lake is available
echo Checking dependencies...
where lake >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Lake not found
    echo Please install Lean 4 first: https://leanprover.github.io/lean4/doc/setup.html
    pause
    exit /b 1
) else (
    echo [OK] Lake found
)

REM Check if Docker is available (optional)
where docker >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Docker found
) else (
    echo [WARNING] Docker not found (optional for containerized runs)
)

echo.
echo Setting up development environment...
lake build
if %errorlevel% neq 0 (
    echo [ERROR] Failed to build project
    pause
    exit /b 1
)

echo.
echo Development environment ready!
echo.
echo Available commands:
echo - lake exe lean-optics help     (run the application)
echo - lake exe test-runner          (run tests)
echo - lake exe bench                (run benchmarks)
echo - scripts\test.bat              (comprehensive tests)
echo.
echo For Docker support:
echo - docker build -t lean-optics .
echo - docker run --rm lean-optics help
echo.
pause
