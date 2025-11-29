#!/usr/bin/env bash
# Smoke tests: verify dry-run paths and presence of tool commands
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR="$SCRIPT_DIR/.."

echo "Starting smoke tests..."

# Check dependencies
echo "Checking dependencies..."
command -v git >/dev/null 2>&1 || { echo "git missing"; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "python3 missing"; exit 1; }

# Check if yq is installed
if ! command -v yq >/dev/null 2>&1; then
  echo "yq missing. Please install it (pip install yq)."
  exit 1
fi

# Test config parser
echo "Testing config parser..."
PARSER="$ROOT_DIR/scripts/config_parser.sh"
CONFIG="$ROOT_DIR/configs/defaults.yml"

VAL=$("$PARSER" "$CONFIG" "global.log_level")
if [[ "$VAL" != "info" ]]; then
  echo "Config parser failed: expected 'info', got '$VAL'"
  exit 1
fi

VAL=$("$PARSER" "$CONFIG" "linux.enable")
if [[ -z "$VAL" ]]; then
  echo "Config parser failed: linux.enable is empty"
  exit 1
fi

echo "Config parser OK"

# Dry run test
echo "Running installer in dry-run mode..."
"$ROOT_DIR/scripts/install_all.sh" --config "$CONFIG" --dry-run

echo "Smoke tests passed!"
