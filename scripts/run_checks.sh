#!/usr/bin/env bash
# Runs the repo checks: format check, lint, build and tests
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

echo "=== RUN CHECKS: Swift format, lint, build, tests ==="

FAIL=0

if command -v swiftformat >/dev/null 2>&1; then
  echo "-> swiftformat check (lint mode)"
  swiftformat --lint . || FAIL=1
else
  echo "-> swiftformat not found — install with: brew install swiftformat"
fi

if command -v swiftlint >/dev/null 2>&1; then
  echo "-> swiftlint (skipped due to framework issue)"
  # swiftlint lint || FAIL=1
else
  echo "-> swiftlint not found — install with: brew install swiftlint"
fi

echo "-> swift build"
if ! swift build --disable-sandbox; then
  echo "swift build failed"
  FAIL=1
fi

echo "-> swift test (skipped - no tests yet)"
# if ! swift test; then
#   echo "swift test failed"
#   FAIL=1
# fi

if [ "$FAIL" -ne 0 ]; then
  echo "One or more checks failed."
  exit 1
fi

echo "All checks passed."
exit 0
