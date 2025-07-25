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
$SettingsFile = Join-Path $TestDir 'Test.runsettings'
$ReportPattern = '**\coverage.cobertura.xml'
$ResultsDir = Join-Path $TestDir 'TestResults'
$SummaryFile = Join-Path $ResultsDir 'Summary.txt'
$HtmlFile = Join-Path $ResultsDir 'index.html'

#───────────────────────────────────────────────────────────────────────────────
# Prerequisites
#───────────────────────────────────────────────────────────────────────────────

# Import the build script and execute it
. "$PSScriptRoot\build.ps1"

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
dotnet test --no-build --nologo --collect:'XPlat Code Coverage' --settings $SettingsFile
Assert-ExitCode 'Tests'

# Generate reports from the coverage results
Write-Host
Write-HostInfo 'Generating coverage report...'
reportgenerator -reports:$ReportPattern -reporttypes:'HtmlInline;TextSummary' -targetdir:$ResultsDir
Assert-ExitCode 'Report Generation'

# Display coverage results in the console
Write-Host
Show-CoverageSummary $SummaryFile

# Open the HTML report

# Open the HTML report
Write-Host
Write-HostSuccess "Tests complete. Report generated in: $ResultsDir"
Start-Process $HtmlFile
