#!/usr/bin/env bash
# Utility helpers used by the install scripts
set -euo pipefail
IFS=$'\n\t'

confirm_or_exit() {
  local yes_flag="$1"
  if [[ "$yes_flag" == "true" ]]; then
    info "--yes provided; continuing without prompt"
    return 0
  fi
  read -r -p "Proceed? [y/N]: " ans
  case "$ans" in
    [Yy]*) return 0;;
    *) error "user aborted"; exit 3;;
  esac
}
