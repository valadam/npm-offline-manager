# manage-packages.ps1

$ErrorActionPreference = "Stop"

# Function to find Git Bash
function Find-GitBash {
    $commonPaths = @(
        "C:\Program Files\Git\bin\bash.exe",
        "C:\Program Files (x86)\Git\bin\bash.exe",
        "$env:PROGRAMFILES\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:USERPROFILE\AppData\Local\Programs\Git\bin\bash.exe"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }
    return $null
}

# Set working directory to script location
Set-Location -Path $PSScriptRoot

# Find Git Bash
$bashPath = Find-GitBash
if (-not $bashPath) {
    Write-Host "Git Bash not found! Please install Git for Windows from https://git-scm.com/download/win" -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Make scripts executable
& $bashPath -c "chmod +x manage-packages.sh setup-npm-offline.sh check-versions.sh"

# Run the package manager
Write-Host "Starting NPM Offline Package Manager..." -ForegroundColor Green
& $bashPath -c "./manage-packages.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host "An error occurred while running the package manager." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit $LASTEXITCODE
}

Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
