#!/usr/bin/env bash
# Common utilities for the installers
set -euo pipefail
IFS=$'\n\t'

# Logging helpers
LOG_LEVEL=${LOG_LEVEL:-"info"}

log() { local lvl="$1"; shift; if [[ "${lvl}" == "error" ]] || [[ "${LOG_LEVEL}" == "debug" ]] || [[ "${LOG_LEVEL}" == "info" && "${lvl}" != "debug" ]]; then printf "%s %s\n" "[mail-installer]" "$*" >&2; fi }
info() { log info "$*"; }
debug() { log debug "$*"; }
error() { log error "$*"; }

# Detect OS (simple normalized values)
detect_os() {
  local uname
  uname=$(uname -s)
  case "${uname}" in
    Linux*)  echo "linux" ;;
    Darwin*) echo "macos" ;;
    *)       echo "unknown" ;;
  esac
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || { error "required command '$1' not found"; exit 2; }
}

# Safe download helper (uses curl or wget)
download() {
  local url="$1" dest="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$dest" "$url"
  else
    error "neither curl nor wget available for downloading $url"; return 1
  fi
}

# Verify checksum (sha256)
verify_checksum() {
  local file="$1" checksum="$2"
  if [[ -z "$checksum" ]]; then
    info "No checksum provided for $file — skipping verification"
    return 0
  fi
  echo "$checksum  $file" | sha256sum -c -
}

check_dependencies() {
  require_command yq
  # Optional: check if yq works as expected (jq wrapper)
  if ! echo "test: 1" | yq -r '.test' >/dev/null 2>&1; then
     error "yq command found but failed basic test. Ensure 'pip install yq' (jq wrapper) is installed, or a compatible yq."
     exit 1
  fi
}

get_config() {
  local config_file="$1"
  local key_path="$2"
  local default_val="${3:-}"
  "$SCRIPT_DIR/config_parser.sh" "$config_file" "$key_path" "$default_val"
}
