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
RESULTS_DIR="$TEST_DIR/TestResults"
HTML_FILE="$RESULTS_DIR/index.html"

#───────────────────────────────────────────────────────────────────────────────
# Prerequisites
#───────────────────────────────────────────────────────────────────────────────

. "$SCRIPT_DIR/build.sh"

#───────────────────────────────────────────────────────────────────────────────
# Function Definitions
#───────────────────────────────────────────────────────────────────────────────

# Function to display the coverage summary
show_coverage_summary() {
    while IFS= read -r line; do
        if [[ $line =~ (Line coverage:|Branch coverage:|Method coverage:) ]]; then
            echo_success "$line"
        else
            echo "$line"
        fi
    done < "$1"
}

#───────────────────────────────────────────────────────────────────────────────
# Script Execution
#───────────────────────────────────────────────────────────────────────────────

echo
echo_info 'Running tests with code coverage...'
dotnet test \
    --nologo \
    --no-restore \
    --no-build \
    --collect:'XPlat Code Coverage' \
    --settings:"$TEST_DIR/Test.runsettings"
assert_exit_code 'Tests'

echo
echo_info 'Generating coverage report...'
reportgenerator \
    -reports:'**/coverage.cobertura.xml' \
    -reporttypes:'HtmlInline;TextSummary' \
    -targetdir:"$RESULTS_DIR"
assert_exit_code 'Report Generation'

# Display coverage results in the console
echo
show_coverage_summary "$RESULTS_DIR/Summary.txt"
echo
echo_success "Tests complete. Report generated in: $RESULTS_DIR"

# Open the HTML report
if [[ "$OSTYPE" == "darwin"* ]]; then # macOS
    open "$HTML_FILE"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then # Linux
    if command -v xdg-open > /dev/null; then
        xdg-open "$HTML_FILE"
    elif command -v gnome-open > /dev/null; then
        gnome-open "$HTML_FILE"
    fi
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "win32" ]]; then # Windows
    start "$HTML_FILE"
elif [[ -n "$(uname -r | grep -i microsoft)" ]]; then # Windows Subsystem for Linux (WSL)
    if command -v wslview > /dev/null; then
        wslview "$HTML_FILE"
    elif command -v powershell.exe > /dev/null; then
        powershell.exe -Command "Start-Process '$(wslpath -w "$HTML_FILE")'"
    elif command -v cmd.exe > /dev/null; then
        cmd.exe /c start "$(wslpath -w "$HTML_FILE")"
    fi
fi
