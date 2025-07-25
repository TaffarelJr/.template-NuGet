#!/usr/bin/env bash
#
# Test script for the NuGet package template.
#
# This script runs tests with code coverage and generates a report.
# It calls the build script first to ensure everything is built correctly.

#───────────────────────────────────────────────────────────────────────────────
# Variable Definitions
#───────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/test"
SETTINGS_FILE="$TEST_DIR/Test.runsettings"
REPORT_PATTERN='**/coverage.cobertura.xml'
RESULTS_DIR="$TEST_DIR/TestResults"
SUMMARY_FILE="$RESULTS_DIR/Summary.txt"
HTML_FILE="$RESULTS_DIR/index.html"

#───────────────────────────────────────────────────────────────────────────────
# Prerequisites
#───────────────────────────────────────────────────────────────────────────────

# Source the build script and execute it
. "$SCRIPT_DIR/build.sh"

#───────────────────────────────────────────────────────────────────────────────
# Function Definitions
#───────────────────────────────────────────────────────────────────────────────

# Function to display the coverage summary
show_coverage_summary() {
    while IFS= read -r line; do
        if [[ $line =~ (Line coverage:|Branch coverage:|Method coverage:) ]]; then
            write_success "$line"
        else
            echo "$line"
        fi
    done < "$1"
}

#───────────────────────────────────────────────────────────────────────────────
# Script Execution
#───────────────────────────────────────────────────────────────────────────────

# Run the tests with code coverage
echo
write_info 'Running tests with code coverage...'
dotnet test --no-build --nologo --collect:'XPlat Code Coverage' --settings "$SETTINGS_FILE"
assert_exit_code 'Tests'

# Generate reports from the coverage results
echo
write_info 'Generating coverage report...'
reportgenerator -reports:"$REPORT_PATTERN" -reporttypes:'HtmlInline;TextSummary' -targetdir:"$RESULTS_DIR"
assert_exit_code 'Report Generation'

# Display coverage results in the console
echo
show_coverage_summary "$SUMMARY_FILE"

# Open the HTML report
echo
write_success "Tests complete. Report generated in: $RESULTS_DIR"
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    open "$HTML_FILE"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v xdg-open > /dev/null; then
        xdg-open "$HTML_FILE"
    elif command -v gnome-open > /dev/null; then
        gnome-open "$HTML_FILE"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then
    # Windows (Git Bash, Cygwin, or native)
    start "$HTML_FILE"
elif [[ -n "$(uname -r | grep -i microsoft)" ]]; then
    # Windows Subsystem for Linux (WSL)
    if command -v wslview > /dev/null; then
        wslview "$HTML_FILE"
    elif command -v powershell.exe > /dev/null; then
        powershell.exe -Command "Start-Process '$(wslpath -w "$HTML_FILE")'"
    elif command -v cmd.exe > /dev/null; then
        cmd.exe /c start "$(wslpath -w "$HTML_FILE")"
    fi
fi
