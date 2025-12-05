#!/usr/bin/env bash
# Convenience helper for committing: runs checks and guides message creation
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

if [ -n "${1-}" ] && [ "$1" = "--help" ]; then
  cat <<EOF
Usage: scripts/commit.sh [files...]

Runs checks (formatting, lint, build, tests) before committing. If checks pass,
prompts for a Conventional Commit-style message and runs git commit.

You may pass a list of files to stage, or stage them manually before running.
EOF
  exit 0
fi

# Safely copy positional parameters into an array even when there are none.
# Using a loop avoids "$@" inside array assignment which can trip set -u in some contexts.
FILES=()
if [ "$#" -gt 0 ]; then
  for arg in "$@"; do
    FILES+=("$arg")
  done
fi

if [ "${#FILES[@]}" -eq 0 ]; then
  echo "No files specified — committing currently staged changes."
else
  echo "Staging: ${FILES[*]}"
  git add -- "${FILES[@]}"
fi

echo "Running checks..."
scripts/run_checks.sh

echo "Checks passed. Preparing commit message."

TYPES=(feat fix docs style refactor perf test chore)
echo "Choose commit type:"
COMMIT_TYPE=""
select type in "${TYPES[@]}"; do
  if [ -n "${type-}" ]; then
    COMMIT_TYPE=$type
    break
  else
    echo "Please choose a valid option."
  fi
done

# Fallback guard in case select exits unexpectedly
if [ -z "${COMMIT_TYPE-}" ]; then
  echo "Aborting: commit type is required."
  exit 1
fi

read -r -p "Short description (imperative, 50 chars max): " SHORT
read -r -p "Optional longer description (press Enter to skip): " BODY

if [ -z "${SHORT-}" ]; then
  echo "Aborting: commit message short description required."
  exit 1
fi

MSG="${COMMIT_TYPE}: ${SHORT}"
if [ -n "${BODY-}" ]; then
  # Use a literal newline in the variable
  MSG="${MSG}

${BODY}"
fi

# Use printf for reliable newlines and avoid relying on echo -e
printf "Committing with message:\n---\n%s\n---\n" "$MSG"

git commit -m "$MSG"

echo "Commit created."
