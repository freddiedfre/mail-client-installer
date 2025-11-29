# Contributing

We follow standard GitHub Flow with protected `main` branch. Use feature branches named `feat/...`, `fix/...`, `chore/...` etc.

## Commit messages
Use **conventional commits**. Examples:
- `feat: add mailspring install option`
- `fix(install): handle flatpak missing`

PRs must pass CI and conventional commit linting. Merges to `main` should be squash-merged.

## Releases
Semantic versioning. Merges to `main` trigger the release workflow which will create GitHub Releases and increment tags according to conventional commit types.
