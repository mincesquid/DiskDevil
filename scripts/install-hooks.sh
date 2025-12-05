#!/usr/bin/env bash
# Installs git hooks by setting core.hooksPath to .githooks in the local repo
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT_DIR"

if [ ! -d ".githooks" ]; then
  echo "Creating .githooks directory"
  mkdir -p .githooks
fi

echo "Installing pre-commit hook path..."
git config core.hooksPath .githooks

echo "Ensuring pre-commit is executable"
chmod +x .githooks/pre-commit || true

echo "Git hooks installed. Pre-commit will run on each commit."
