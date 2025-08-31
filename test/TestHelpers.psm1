using namespace System
using namespace System.IO

<#
.SYNOPSIS
Finds all test project files in the test directory.

.DESCRIPTION
Recursively searches the test directory for .csproj files and returns them.

.OUTPUTS
System.IO.FileInfo[]
An array of FileInfo objects representing the test project files found.
#>
function Get-TestProjects {
    [CmdletBinding()]
    param()

    return Get-ChildItem -Path 'test' -Recurse -Filter '*.csproj'
}

<#
.SYNOPSIS
Extracts the target framework(s) from the given project file.

.DESCRIPTION
Parses the provided .csproj file to extract the
TargetFramework or TargetFrameworks property values.
Handles both single-framework and multi-framework project configurations.

.PARAMETER Project
The path to the project file (.csproj) to analyze.

.OUTPUTS
System.String[]
An array of strings representing the target frameworks defined in the project.
#>
function Get-TargetFrameworks {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string]$Project
    )

    process {
        return ([xml](Get-Content -Path $Project -Raw)).Project.PropertyGroup `
        | ForEach-Object {
            if ($_.TargetFrameworks) { $_.TargetFrameworks }
            elseif ($_.TargetFramework) { $_.TargetFramework }
        } `
        | ForEach-Object { $_ -Split ';' }
    }
}

<#
.SYNOPSIS
Identifies the test run(s) required for the given project file.

.DESCRIPTION
Returns an array of custom objects identifying various test run settings
that are required to fully test the given project file.

.PARAMETER Project
The path to the project file (.csproj) to analyze.

.OUTPUTS
System.Management.Automation.PSCustomObject[]
An array of custom objects containing various test run settings.
#>
function Get-TestRuns {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName', 'Path')]
        [string]$Project
    )

    process {
        $directory = [Path]::GetDirectoryName($Project)
        return $Project | Get-TargetFrameworks | ForEach-Object {
            [PSCustomObject]@{
                Directory = $directory
                Project   = $Project
                Framework = $_
                Output    = Join-Path $directory 'TestResults' $_
            }
        }
    }
}

<#
.SYNOPSIS
Outputs a formatted test header to the console.

.DESCRIPTION
Creates a visually distinct header bar
with a text message surrounded by separator lines.

.PARAMETER TestRun
A custom object containing test run configuration details including the project,
framework, and directory information.
#>
function Write-TestHeader {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject]$TestRun
    )

    process {
        $separator = "─" * 80
        $color1 = [ConsoleColor]::Cyan
        $color2 = [ConsoleColor]::Yellow

        Write-Host
        Write-Host $separator -ForegroundColor $color1
        Write-Host 'Running tests for ' -ForegroundColor $color1 -NoNewline
        Write-Host $TestRun.Framework -ForegroundColor $color2
        Write-Host $separator -ForegroundColor $color1
        return $TestRun
    }
}

<#
.SYNOPSIS
Executes the specified test run.

.DESCRIPTION
Executes a test run for a specific test project and target framework.

.PARAMETER TestRun
A custom object containing test run configuration details including the project,
framework, and directory information.

.OUTPUTS
System.Management.Automation.PSCustomObject
Returns the same TestRun object that was passed in, enabling pipeline chaining.
#>
function Invoke-DotnetTest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject]$TestRun
    )

    process {
        Start-Process -FilePath 'dotnet' -ArgumentList @(
            'test'
            $TestRun.Project
            '--nologo'
            '--no-restore'
            '--no-build'
            "--configuration:Release"
            "--framework:$($TestRun.Framework)"
            '--collect:"XPlat Code Coverage"'
            '--settings:test\Test.runsettings'
            "--results-directory:`"$($TestRun.Output)`""
            "--logger:`"junit;LogFilePath=$($TestRun.Output)\results.junit.xml;MethodFormat=Full;FailureBodyFormat=Verbose`""
        ) -NoNewWindow -Wait

        return $TestRun
    }
}

function Publish-TestCoverage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject]$TestRun
    )

    process {
        $file = Get-ChildItem -Path $TestRun.Output -Recurse -Filter '*.cobertura.xml' `
        | Select-Object -First 1

        Start-Process -FilePath 'codecov' -ArgumentList @(
            'upload-coverage'
            '--token', $Env:CODECOV_TOKEN
            '--git-service', 'github'
            '--branch', $Env:GITHUB_REF_NAME
            '--sha', $Env:GITHUB_SHA
            '--fail-on-error'
            '--disable-search'
            '--file', $file.FullName
            '--flag', $TestRun.Framework
            '--name', "github-$Env:GITHUB_RUN_ID-$($TestRun.Framework)"
        ) -NoNewWindow -Wait

        return $TestRun
    }
}

function Publish-TestResults {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [PSCustomObject]$TestRun
    )

    process {
        $file = Get-ChildItem -Path $TestRun.Output -Filter '*.junit.xml' `
        | Select-Object -First 1

        Start-Process -FilePath 'codecov' -ArgumentList @(
            'do-upload'
            '--token', $Env:CODECOV_TOKEN
            '--git-service', 'github'
            '--branch', $Env:GITHUB_REF_NAME
            '--sha', $Env:GITHUB_SHA
            '--fail-on-error'
            '--disable-search'
            '--report-type', 'test_results'
            '--file', $file.FullName
            '--flag', $TestRun.Framework
            '--name', "github-$Env:GITHUB_RUN_ID-$($TestRun.Framework)"
        ) -NoNewWindow -Wait

        return $TestRun
    }
}

# Export the functions
Export-ModuleMember -Function Get-TestProjects
Export-ModuleMember -Function Get-TargetFrameworks
Export-ModuleMember -Function Get-TestRuns
Export-ModuleMember -Function Write-TestHeader
Export-ModuleMember -Function Invoke-DotnetTest
Export-ModuleMember -Function Publish-TestCoverage
Export-ModuleMember -Function Publish-TestResults
