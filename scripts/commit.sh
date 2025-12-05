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

FILES=("${@}")

if [ ${#FILES[@]} -eq 0 ]; then
  echo "No files specified — committing currently staged changes."
else
  echo "Staging: ${FILES[*]}"
  git add "${FILES[@]}"
fi

echo "Running checks..."
scripts/run_checks.sh

echo "Checks passed. Preparing commit message."

TYPES=(feat fix docs style refactor perf test chore)
echo "Choose commit type:"
select type in "${TYPES[@]}"; do
  if [ -n "$type" ]; then
    COMMIT_TYPE=$type
    break
  fi
done

read -r -p "Short description (imperative, 50 chars max): " SHORT
read -r -p "Optional longer description (press Enter to skip): " BODY

if [ -z "$SHORT" ]; then
  echo "Aborting: commit message short description required."
  exit 1
fi

MSG="$COMMIT_TYPE: $SHORT"
if [ -n "$BODY" ]; then
  MSG+="\n\n$BODY"
fi

echo "Committing with message:\n---\n$MSG\n---"

git commit -m "$MSG"

echo "Commit created."
