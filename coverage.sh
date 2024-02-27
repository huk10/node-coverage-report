#!/usr/bin/env bash
set -euo pipefail

OUTPUT="$1"
SCRIPT="${INPUT_SCRIPT-}"
COVERAGE_DIR="${INPUT_COVERAGE_DIR-}"

mkdir -p "$OUTPUT"

if [ -z "$SCRIPT" ]; then
  SCRIPT="npm run test:coverage"
fi

if [ -z "$COVERAGE_DIR" ]; then
  COVERAGE_DIR="coverage"
fi

# Extract total coverage: the decimal number from the last line of the function report.
# Give priority to taking values from json files
TEST_RESULT=$(eval "$SCRIPT")
if [ -f "./$COVERAGE_DIR/coverage-summary.json" ]; then
  COVERAGE=$(< "./$COVERAGE_DIR/coverage-summary.json" jq .total.statements.pct)
else
  # Try to take a value from the command output，
  COVERAGE=$(echo "$TEST_RESULT" | grep "Statements" | grep -oE '[0-9]+\.[0-9]+%')
  # Remove the percent sign
  COVERAGE=${COVERAGE%?}
fi

# Can not get a value to exit
if [ -z "$COVERAGE" ]; then
  exit 2
fi

echo "coverage: $COVERAGE% of statements"

# Pick a color for the badge.
if awk "BEGIN {exit !($COVERAGE >= 90)}"; then
	COLOR=brightgreen
elif awk "BEGIN {exit !($COVERAGE >= 80)}"; then
	COLOR=green
elif awk "BEGIN {exit !($COVERAGE >= 70)}"; then
	COLOR=yellowgreen
elif awk "BEGIN {exit !($COVERAGE >= 60)}"; then
	COLOR=yellow
elif awk "BEGIN {exit !($COVERAGE >= 50)}"; then
	COLOR=orange
else
	COLOR=red
fi

# Style for the badge.
STYLE="${INPUT_BADGE_STYLE-}"
# Title for the badge.
TITLE="${INPUT_BADGE_TITLE-}"

# Download the badge.
curl -s "https://img.shields.io/badge/$(printf %s "$TITLE" | jq -sRr @uri)-$COVERAGE%25-$COLOR?style=$STYLE" > "$OUTPUT/coverage.svg"
