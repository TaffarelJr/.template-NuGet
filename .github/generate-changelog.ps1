#requires -Version 7.0

<#
.SYNOPSIS
    Generates a changelog from Git commit history.

.DESCRIPTION
    This script generates a Markdown file that contains the commit history
    since the last release tag (on the current branch).

.PARAMETER OutputPath
    (Optional) The path for the output changelog file.
    If not specified, defaults to 'changelog.md'.

.PARAMETER FromVersion
    (Optional) A specific release tag.
    If given, the script will generate commit history
    starting from this tag instead.
#>

[CmdletBinding()]
param(
    [string]$OutputPath,

    [string]$FromVersion
)

#───────────────────────────────────────────────────────────────────────────────
# Configuration
#───────────────────────────────────────────────────────────────────────────────

# This defines the Conventional Commit categories (and their display names)
# along with the order in which they will appear in the changelog
# (from most important to least important).
$categories = [ordered]@{
    'break'    = '💥 BREAKING CHANGES' # virtual category

    'revert'   = '↩️  Reverted Changes'
    'feat'     = '✨ New Features'
    'fix'      = '🐛 Bug Fixes'
    'refactor' = '🔄 Code Refactoring'
    'perf'     = '⚡️ Performance Improvements'
    'test'     = '🧪 Tests'
    'infra'    = '🛠️  Infrastructure'
    'build'    = '📦 Build System'
    'ci'       = '🤖 Continuous Integration'
    'docs'     = '📚 Documentation'
    'style'    = '🎨 Code Style'
    'chore'    = '🔧 Maintenance'
    # 'other' goes here

    'merge'    = '🔀 Pull Requests'
}

# We can't output Git commit messages as JSON because they might contain newlines.
# We must use a delimited export instead.
# As such, we must define custom delimiters to avoid conflicts with the messages.
# These must be a SINGLE char, and as obscure as possible.
# (JSON doesn't work for the export, because the commit message might contain newlines.)
$commitDelimiter = 'ↄ'
$fieldDelimiter = 'ⅎ'

# Scopes are written as a badge in the changelog.
# This defines the style of the badge.
$badgeStyle = 'plastic' # [flat|flat-square|plastic|for-the-badge|social]

#───────────────────────────────────────────────────────────────────────────────
# Helper Functions
#───────────────────────────────────────────────────────────────────────────────

# Ensures that a PowerShell module is installed and imported.
function Install-RequiredModule {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ModuleName
    )

    process {
        $module = Get-Module -ListAvailable -Name $ModuleName

        if (-not $module) {
            Write-Host "Installing $ModuleName module..." -ForegroundColor Yellow
            Install-Module -Name $ModuleName -Force -Scope CurrentUser -AllowClobber
        }

        Import-Module -Name $ModuleName -Force
    }
}

# Gets all tags from Git history.
function Get-AllTags {
    return git show-ref --tags `
    | ForEach-Object {
        $parts = $_ -split '\s+', 2

        [PSCustomObject]@{
            Sha = $parts[0]
            Tag = $parts[1] -replace '^refs/tags/', ''
        }
    }
}

# Gets all version tags from Git history.
function Get-AllVersionTags {
    return Get-AllTags `
    | Where-Object { $_.Tag -match '^v' } `
    | ForEach-Object {
        [PSCustomObject]@{
            Sha     = $_.Sha
            Tag     = $_.Tag
            Version = New-PSSemVer -Version $($_.Tag -replace '^v', '')
        }
    } `
    | Sort-Object { $_.Version } -Descending
}

# Finds the commit for the previous release tag.
function Get-PreviousRelease {
    param(
        [Parameter(Mandatory)]
        [string]$ExcludeSha
    )

    return Get-AllVersionTags `
    | Where-Object { $_.Sha -ne $ExcludeSha } `
    | Select-Object -First 1
}

# Finds the commit for the specified release tag.
function Get-SpecifiedRelease {
    param(
        [Parameter(Mandatory)]
        [string]$Tag
    )

    return Get-AllVersionTags `
    | Where-Object { $_.Tag -match $Tag } `
    | Select-Object -First 1
}

# Gets the first commit in the repository history.
function Get-FirstCommit {
    $firstCommitSha = git rev-list --max-parents=0 HEAD
    return [PSCustomObject]@{
        Sha     = $firstCommitSha
        Tag     = 'initial commit'
        Version = $null
    }
}

# Determines the appropriate baseline commit.
function Get-BaselineCommit {
    param(
        [Parameter(Mandatory)]
        [string]$CurrentSha
    )

    if ($FromVersion) {
        $result = Get-SpecifiedRelease $FromVersion
        if (-not $result) {
            throw "Specified version '$FromVersion' was not found in the repository."
        }
    }
    else {
        $result = Get-PreviousRelease $CurrentSha
        if (-not $result) {
            $result = Get-FirstCommit
        }
    }

    return $result
}

# Get the commit history between two SHAs and parse Conventional Commits
function Get-CommitHistory {
    param(
        [Parameter(Mandatory)]
        [string]$StartSha, # exclusive

        [Parameter(Mandatory)]
        [string]$EndSha    # inclusive
    )

    $history = git log --reverse "$StartSha..$EndSha" --format="%H$fieldDelimiter%s$fieldDelimiter%b$commitDelimiter"
    if (-not $history) {
        return @()
    }

    return $history -split $commitDelimiter `
    | ForEach-Object { $_.Trim() } `
    | Where-Object { $_ -ne '' } `
    | ForEach-Object {
        $fields = $_ -split $fieldDelimiter, 3

        [PSCustomObject]@{
            Sha     = $fields[0].Trim()
            Subject = $fields[1].Trim()
            Body    = if ($fields.Count -gt 2) { $fields[2].Trim() } else { '' }
        }
    }
}

# Extracts Conventional Commits information from the given commit.
function ConvertTo-ParsedCommit {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Commit
    )

    process {
        $isMergeCommit = $Commit.Subject.StartsWith('Merge pull request #')
        $hasBreakingChange = $Commit.Body -imatch 'breaking\s*(?:changes?)?\s*:'
        $isConventional = $Commit.Subject -imatch '^\s*([a-z]+)\s*(\([^)]*\))?\s*(!)?:\s*(.+?)\s*$'
        $hasBang = $isConventional -and ($Matches[3] -eq '!')

        [PSCustomObject]@{
            Sha           = $Commit.Sha
            Subject       = $Commit.Subject
            Type          = $isConventional ? $Matches[1].ToLower() : ''
            Scope         = $isConventional ? (($Matches[2] -replace '[()]', '').Trim()) : ''
            Description   = $isConventional ? $Matches[4].Trim() : $Commit.Subject
            Body          = $Commit.Body
            IsBreaking    = $hasBang -or $hasBreakingChange
            IsMergeCommit = $isMergeCommit
        }
    }
}

# Extracts commits that match the specified category
# and removes them from the source array.
function Split-CommitsForCategory {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.DictionaryEntry]$Category,

        [Parameter(Mandatory)]
        [ref]$Commits
    )

    process {
        if ($Category.Key -eq 'break') {
            return @($Commits.Value | Where-Object { $_.IsBreaking })
        }

        $matchedCommits = $Category.Key -eq 'merge' `
            ? ($Commits.Value | Where-Object { $_.IsMergeCommit }) `
            : ($Commits.Value | Where-Object { $_.Type -eq $Category.Key })

        $Commits.Value = @($Commits.Value | Where-Object { $_.Sha -notin $matchedCommits.Sha })
        return @($matchedCommits)
    }
}

# Hashes the given text and converts it to a hex color value.
function Get-ScopeColor {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Scope
    )

    process {
        $hasher = [System.Security.Cryptography.SHA256]::Create()
        try {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($Scope)
            $hash = $hasher.ComputeHash($bytes)
            $hashString = [System.BitConverter]::ToString($hash) -replace '-', ''
            return $hashString.Substring(40, 6)
        }
        finally {
            $hasher.Dispose()
        }
    }
}

# Generates Markdown text for a shields.io badge for the given commit's scope.
function Get-ScopeBadge {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Commit
    )

    process {
        if (-not $Commit.Scope) {
            return $null
        }

        $encodedScope = [System.Web.HttpUtility]::UrlPathEncode($Commit.Scope)
        $color = Get-ScopeColor $Commit.Scope
        $url = "https://img.shields.io/badge/$encodedScope-$($color)?style=$badgeStyle"
        return "![$($Commit.Scope)]($url) "
    }
}

# Writes a single commit to the changelog file.
function Write-CommitToChangelog {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [PSCustomObject]$Commit,

        [Parameter(Mandatory)]
        [System.Collections.DictionaryEntry]$Category
    )

    process {
        if ($Category.Key -eq 'other' -and $Commit.Type) {
            $prefix = "$($Commit.Type): "
        }

        $scope = Get-ScopeBadge $Commit

        if ($Category.Key -ne 'break' -and $Commit.IsBreaking) {
            $suffix = ' 💥'
        }

        Add-Content -Path $OutputPath -Value "- $prefix$scope$($Commit.Description)$suffix"

        if ($Commit.Body) {
            $Commit.Body -split '`n' `
            | ForEach-Object {
                Add-Content -Path $OutputPath -Value "  > $($_.Trim())  "
            }
        }
    }
}

# Writes all commits in a category to the changelog file.
function Write-CategoryToChangeLog {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Collections.DictionaryEntry]$Category,

        [Parameter(Mandatory)]
        [array]$Commits
    )

    if (-not $Commits -or $Commits.Count -eq 0) {
        return
    }

    $titleWithCount = "$($Category.Value) ($($Commits.Count))"
    Write-Host "    $titleWithCount"

    Add-Content -Path $OutputPath -Value "## $titleWithCount"
    Add-Content -Path $OutputPath -Value ''

    if ($Category.Key -eq 'break') {
        Add-Content -Path $OutputPath -Value '_(Aggregated from the other categories below.)_'
        Add-Content -Path $OutputPath -Value ''
    }

    $Commits | Write-CommitToChangelog -Category $Category
    Add-Content -Path $OutputPath -Value ''
}

# Converts a markdown file to YAML-safe text format.
function ConvertTo-YamlSafeText {
    param(
        [Parameter(Mandatory)]
        [string]$MarkdownPath,

        [Parameter(Mandatory)]
        [string]$SafePath
    )

    if (Test-Path $SafePath) { Remove-Item $SafePath -Force }
    New-Item -Path $SafePath -ItemType File -Force | Out-Null

    $content = Get-Content -Path $MarkdownPath -Raw
    $content = $content -replace '^(\s*)-', '  •'  # Replace markdown list markers with bullets
    $content = $content -replace '^(\s*)##', '  **'  # Replace markdown headers
    $content = $content -replace '`', "'"  # Replace backticks with single quotes
    Set-Content -Path $SafePath -Value $content -Encoding UTF8
}

#───────────────────────────────────────────────────────────────────────────────
# Execution
#───────────────────────────────────────────────────────────────────────────────

'PSSemVer' | Install-RequiredModule

if (-not $OutputPath) { $OutputPath = 'changelog.md' }
if (Test-Path $OutputPath) { Remove-Item $OutputPath -Force }
New-Item -Path $OutputPath -ItemType File -Force | Out-Null

$currentSha = git rev-parse HEAD
$baseline = Get-BaselineCommit $currentSha
Write-Host "Current commit:  $currentSha"
Write-Host "Baseline commit: $($baseline.Sha) ($($baseline.Tag))"

Write-Host 'Loading commit history'
$commits = Get-CommitHistory $baseline.Sha $currentSha `
| ConvertTo-ParsedCommit

Write-Host "Generating changelog: ($($commits.Count.ToString('N0')) commits)"
foreach ($category in $categories.GetEnumerator()) {
    $categoryCommits = Split-CommitsForCategory $category ([ref]$commits)

    if ($category.Key -eq 'merge') {
        $mergeCategory = $category
        $mergeCommits = $categoryCommits
    }
    elseif ($categoryCommits -and $categoryCommits.Count -gt 0) {
        Write-CategoryToChangeLog $category $categoryCommits
    }
}

if ($commits -and $commits.Count -gt 0) {
    $other = [System.Collections.DictionaryEntry]::new('other', 'Other')
    Write-CategoryToChangeLog $other $commits
}

if ($mergeCommits -and $mergeCommits.Count -gt 0) {
    Write-CategoryToChangeLog $mergeCategory $mergeCommits
}

ConvertTo-YamlSafeText -MarkdownPath $OutputPath -SafePath 'changelog.safe.txt'
Write-Host "Changelog generated successfully: $OutputPath"
