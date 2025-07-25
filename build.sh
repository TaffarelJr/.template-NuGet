#!/usr/bin/env bash
#
# Build script for the NuGet package template.
#
# This script handles various setup and build tasks for the NuGet package template.

#───────────────────────────────────────────────────────────────────────────────
# Variable Definitions
#───────────────────────────────────────────────────────────────────────────────

TEST_RESULTS="TestResults"

#───────────────────────────────────────────────────────────────────────────────
# Function Definitions
#───────────────────────────────────────────────────────────────────────────────

# Writes informational messages
write_info() {
    echo -e "\e[34m$1\e[0m"
}

# Writes success messages
write_success() {
    echo -e "\e[32m$1\e[0m"
}

# Checks exit code and exits on failure
assert_exit_code() {
    if [ $? -ne 0 ]; then
        echo -e "\e[31m$1 failed with exit code $?\e[0m"
        exit $?
    fi
}

#───────────────────────────────────────────────────────────────────────────────
# Script Execution
#───────────────────────────────────────────────────────────────────────────────

# Configure git to use the existing .gitmessage template for this repo
git config --local commit.template .gitmessage
write_success 'Git commit message template configured'

# Clean previous build artifacts
echo
write_info 'Cleaning previous build artifacts...'
dotnet clean --nologo
find "$(dirname "$0")" -name "$TEST_RESULTS" -type d -exec rm -rf {} +
assert_exit_code 'Clean'

# Restore .NET tools
echo
write_info 'Restoring .NET tools...'
dotnet tool restore
assert_exit_code 'Tool Restore'

# Restore NuGet packages
echo
write_info 'Restoring NuGet packages...'
dotnet restore --nologo
assert_exit_code 'Package Restore'

# Build the solution
echo
write_info 'Building solution...'
dotnet build --nologo --no-restore
assert_exit_code 'Build'

echo
write_success 'Build completed successfully.'
