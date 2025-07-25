<#
.SYNOPSIS
Build script for the NuGet package template.

.DESCRIPTION
This script handles various setup and build tasks for the NuGet package template.
#>

#───────────────────────────────────────────────────────────────────────────────
# Function Definitions
#───────────────────────────────────────────────────────────────────────────────

# Writes informational messages
function Write-HostInfo($message) {
    Write-Host $message -ForegroundColor Blue
}

# Writes success messages
function Write-HostSuccess($message) {
    Write-Host $message -ForegroundColor Green
}

# Checks exit code and exits on failure
function Assert-ExitCode($command) {
    if ($LASTEXITCODE -ne 0) {
        Write-Host "$command failed with exit code $LASTEXITCODE" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

#───────────────────────────────────────────────────────────────────────────────
# Script Execution
#───────────────────────────────────────────────────────────────────────────────

# Configure git to use the existing .gitmessage template for this repo
git config --local commit.template .gitmessage
Write-HostSuccess 'Git commit message template configured'

# Clean previous build artifacts
Write-Host
Write-HostInfo 'Cleaning previous build artifacts...'
dotnet clean --nologo
Get-ChildItem -Path $PSScriptRoot -Include 'TestResults' -Directory -Recurse `
| ForEach-Object { Remove-Item -Path $_.FullName -Recurse -Force }
Assert-ExitCode 'Clean'

# Restore .NET tools
Write-Host
Write-HostInfo 'Restoring .NET tools...'
dotnet tool restore
Assert-ExitCode 'Tool Restore'

# Restore NuGet packages
Write-Host
Write-HostInfo 'Restoring NuGet packages...'
dotnet restore --nologo
Assert-ExitCode 'Package Restore'

# Build the solution
Write-Host
Write-HostInfo 'Building solution...'
dotnet build --nologo --no-restore
Assert-ExitCode 'Build'

Write-Host
Write-HostSuccess 'Build completed successfully.'
