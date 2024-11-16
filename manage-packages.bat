@echo off
title NPM Offline Package Manager

echo =================================================
echo  NPM Offline Package Manager
echo  Copyright (c) 2024 Val Adam. All rights reserved.
echo  Version 1.0.0
echo =================================================
echo.

cd /d "%~dp0"

REM Check if npm-offline-cache exists
if not exist "npm-offline-cache" (
    echo First time setup detected!
    echo No packages are currently installed.
    echo Please use option 4 from the menu to run the full setup.
    echo.
)

echo Starting NPM Offline Package Manager...
echo Current directory: %CD%

REM Try to find Git Bash
if exist "C:\Program Files\Git\bin\bash.exe" (
    set "BASH_EXE=C:\Program Files\Git\bin\bash.exe"
) else if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    set "BASH_EXE=C:\Program Files (x86)\Git\bin\bash.exe"
) else (
    echo Git Bash not found!
    echo Please install Git for Windows
    pause
    exit /b 1
)

echo Found Git Bash at: "%BASH_EXE%"
echo Running package manager...
echo.

REM Make scripts executable
"%BASH_EXE%" -c "chmod +x manage-packages.sh setup-npm-offline.sh check-versions.sh"

"%BASH_EXE%" -c "./manage-packages.sh"
if errorlevel 1 (
    echo Error occurred while running the package manager
    pause
    exit /b 1
)

echo.
echo Script finished. Press any key to exit...
pause >nul
