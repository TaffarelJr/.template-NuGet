<#
.SYNOPSIS
Test script for the NuGet package template.

.DESCRIPTION
This script runs tests with code coverage and generates a report.
It calls the build script first to ensure everything is built correctly.
#>

#───────────────────────────────────────────────────────────────────────────────
# Variable Definitions
#───────────────────────────────────────────────────────────────────────────────

$TestDir = Join-Path $PSScriptRoot 'test'
$ResultsDir = Join-Path $TestDir 'TestResults'

#───────────────────────────────────────────────────────────────────────────────
# Prerequisites
#───────────────────────────────────────────────────────────────────────────────

# Import the build script and execute it
. (Join-Path $PSScriptRoot 'build.ps1')

#───────────────────────────────────────────────────────────────────────────────
# Function Definitions
#───────────────────────────────────────────────────────────────────────────────

# Function to display the coverage summary
function Show-CoverageSummary($file) {
    Get-Content $file | ForEach-Object {
        if ($_ -Match "Line coverage:|Branch coverage:|Method coverage:") {
            Write-HostSuccess $_
        }
        else {
            Write-Host $_
        }
    }
}

#───────────────────────────────────────────────────────────────────────────────
# Script Execution
#───────────────────────────────────────────────────────────────────────────────

# Run the tests with code coverage
Write-Host
Write-HostInfo 'Running tests with code coverage...'
dotnet test `
    --nologo `
    --no-restore `
    --no-build `
    --collect:'XPlat Code Coverage' `
    --settings:"$(Join-Path $TestDir 'Test.runsettings')"
Assert-ExitCode 'Tests'

# Generate reports from the coverage results
Write-Host
Write-HostInfo 'Generating coverage report...'
reportgenerator `
    -reports:"$(Join-Path '**' 'coverage.cobertura.xml')" `
    -reporttypes:'HtmlInline;TextSummary' `
    -targetdir:"$ResultsDir"
Assert-ExitCode 'Report Generation'

# Display coverage results in the console
Write-Host
Show-CoverageSummary (Join-Path $ResultsDir 'Summary.txt')
Write-Host
Write-HostSuccess "Tests complete. Report generated in: $ResultsDir"

# Open the HTML report
Start-Process (Join-Path $ResultsDir 'index.html')
