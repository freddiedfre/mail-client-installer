#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN: $*"
  else
    eval "$@"
  fi
}

check_binary() {
  local name="$1" shift_cmd="$2" gui_hint="${3:-false}"
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "DRY RUN: would check $name"
    return 0
  fi
  if command -v $(echo "$shift_cmd" | awk '{print $1}') >/dev/null 2>&1; then
    echo "=== $name version ==="
    eval "$shift_cmd" || true
    echo "====================="
  else
    if [[ "$gui_hint" == "true" ]]; then
      echo "NOTICE: $name appears to be a GUI-only app. Please verify via Applications folder or .app bundle."
    else
      echo "ERROR: $name binary not found in PATH"
      exit 2
    fi
  fi
}

echo "Running per-client smoke checks (dry-run=$DRY_RUN)"

check_binary "mutt" "mutt -v"
check_binary "neomutt" "neomutt -v"
check_binary "alpine" "alpine -v || true"

check_binary "thunderbird" "thunderbird --version" true
check_binary "evolution" "evolution --version" true
check_binary "kmail" "kmail --version" true

check_binary "mailspring" "mailspring --version" true

if [[ "$(uname -s)" == "Darwin" ]]; then
  echo "macOS checks:"
  if command -v brew >/dev/null 2>&1; then
    echo "Checking Homebrew cask list (if installed):"
    brew list --casks || true
  fi
fi

echo "Per-client smoke checks completed."
