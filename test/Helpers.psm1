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
        $relativePath = [Path]::GetRelativePath((Get-Location), $Project)
        $relativeDir = [Path]::GetDirectoryName($relativePath)

        return $Project | Get-TargetFrameworks | ForEach-Object {
            [PSCustomObject]@{
                Directory = $relativeDir
                Project   = $relativePath
                Framework = $_
            }
        }
    }
}

# Executes the specified test run
function Invoke-TestCommand {
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

        Write-Host $separator -ForegroundColor $color1
        Write-Host 'Running tests for ' -ForegroundColor $color1 -NoNewline
        Write-Host $TestRun.Framework -ForegroundColor $color2
        Write-Host $separator -ForegroundColor $color1

        $command = "dotnet test '$($TestRun.Project)'" +
        ' --nologo' +
        ' --no-restore' +
        ' --no-build' +
        ' --configuration:Release' +
        " --framework:$($TestRun.Framework)" +
        ' --settings:''test\Test.runsettings''' +
        ' --collect:''XPlat Code Coverage''' +
        " --results-directory:'$($TestRun.Directory)\TestResults\$($TestRun.Framework)'" +
        " --logger:'junit;LogFilePath=TestResults\$($TestRun.Framework)\results.junit.xml;MethodFormat=Full;FailureBodyFormat=Verbose'"

        Invoke-Expression $command
    }
}






function Get-Flags {
    [CmdletBinding()]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string]$Project
    )

    # Get all unique frameworks, join with commas, and replace periods with underscores
    # Get-TestProjects | Get-TargetFrameworks | Sort-Object -Unique | ForEach-Object { $_ -replace '\.', '_' } | Join-String -Separator ','

    process {
        return $Project `
        | Get-TargetFrameworks `
        | ForEach-Object {
            [PSCustomObject]@{
                Directory = $relativeDir
                Project   = $relativePath
                Framework = $_
            }
        }
    }
}



# Generates test steps for each target framework
function Get-TestSteps {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Frameworks
    )

    $steps = $Frameworks | ForEach-Object { @"
- name: Test $_
  needs: [ checkout ]
  run: >
    dotnet test
    --nologo
    --no-restore
    --no-build
    --configuration Release
    --framework $_
    --settings test/Test.runsettings
    --collect:'XPlat Code Coverage'
    --results-directory:'TestResults/$_'
"@ } | Join-String -Separator "`n"

    return $steps
}

# Generates the list of flags for Codecov
function Get-CodecovFlags {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Frameworks
    )

    # Generate flags (to match codecov.yml)
    $allFrameworks = $Frameworks + @('netFramework', 'netCore', 'dotnet')
    $flags = $allFrameworks `
    | ForEach-Object { $_ -replace '\.', '_' } `
    | Join-String -Separator ','

    return $flags
}

# Export the functions
Export-ModuleMember -Function Get-TestProjects
Export-ModuleMember -Function Get-TargetFrameworks
Export-ModuleMember -Function Get-TestRuns
Export-ModuleMember -Function Invoke-TestCommand
Export-ModuleMember -Function Get-TestSteps
Export-ModuleMember -Function Get-CodecovFlags
