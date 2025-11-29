#!/usr/bin/env bash
# Entry point that auto-detects OS and runs the appropriate installer
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=./install_common.sh
source "$SCRIPT_DIR/install_common.sh"

CONFIG=${CONFIG:-configs/local.yml}
DRY_RUN=false
YES=false

# parse args
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --config) CONFIG="$2"; shift 2;;
    --dry-run) DRY_RUN=true; shift;;
    --yes) YES=true; shift;;
    --help) echo "Usage: $0 [--config path] [--dry-run] [--yes]"; exit 0;;
    *) shift;;
  esac
done

export CONFIG DRY_RUN YES

# Resolve absolute path for config if it's relative
if [[ ! "$CONFIG" = /* ]]; then
  # Assume relative to current working directory where script is called
  CONFIG="$(pwd)/$CONFIG"
fi

OS=$(detect_os)
case "$OS" in
  linux)
    if [[ "$DRY_RUN" == "true" ]]; then
      "$SCRIPT_DIR/install_ubuntu.sh" "$CONFIG"
    else
      sudo -E "$SCRIPT_DIR/install_ubuntu.sh" "$CONFIG"
    fi
    ;;
  macos)
    "$SCRIPT_DIR/install_macos.sh" "$CONFIG"
    ;;
  *)
    error "Unsupported OS: $OS"
    ;;
esac

info "All done."
