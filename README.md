# MadScientist

## Developer / Commit automation

This repo contains helper scripts and a GitHub Actions CI workflow to help keep commits clean and tests passing.

Local tools used by the automation (recommended):

- swiftformat — formatting checks
- swiftlint — lint checks

Install with Homebrew:

```bash
brew install swiftformat swiftlint
```

Install the repository git-hooks (sets `core.hooksPath`) so pre-commit runs automatically:

```bash
./scripts/install-hooks.sh
```

Committing via the helper will run checks and guide you through creating a conventional commit message.

```bash
# Stage files then run
git add .
./scripts/commit.sh

# Or pass files to stage and commit
./scripts/commit.sh path/to/file1 path/to/file2
```

CI (GitHub Actions) will run on pushes and pull requests to `main` and checks formatting, lint, build, and tests.

