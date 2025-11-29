#!/usr/bin/env bash
set -euo pipefail

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not installed; skipping shellcheck (CI will run this)."; exit 0
fi

shellcheck scripts/*.sh

echo "lint OK"
