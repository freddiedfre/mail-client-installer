#!/usr/bin/env bash
# Wrapper around yq to parse config files
# Usage: config_parser.sh <config_file> <key_path> [default_value]

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <config_file> <key_path> [default_value]" >&2
  exit 1
fi

CONFIG_FILE="$1"
KEY_PATH="$2"
DEFAULT_VAL="${3:-}"

if [[ ! -f "$CONFIG_FILE" ]]; then
  # If config file missing, return default
  echo "$DEFAULT_VAL"
  exit 0
fi

# Check for yq
if ! command -v yq >/dev/null 2>&1; then
  echo "Error: yq is not installed. Please install it (e.g. pip install yq)" >&2
  exit 1
fi

# Construct jq-style query
# We handle:
# 1. Key lookup
# 2. Default value if null
# 3. Flatten array to newlines if it is an array
# 4. Output raw strings

# Note: We assume yq is the wrapper around jq (pip install yq) or compatible.
# If using mikefarah/yq, syntax might differ. We target the jq-compatible one as it's common in python envs.

# Prepend . to key path if not present
if [[ "$KEY_PATH" != .* ]]; then
  QUERY=".$KEY_PATH"
else
  QUERY="$KEY_PATH"
fi

# Use yq with -r (raw output)
# Logic: .key // $default | if type=="array" then .[] else . end
# We use --arg for default value to handle special chars safely

yq -r --arg def "$DEFAULT_VAL" "${QUERY} // \$def | if type==\"array\" then .[] else . end" "$CONFIG_FILE"
