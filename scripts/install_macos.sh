#!/usr/bin/env bash
# Install mail clients on macOS
set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/install_common.sh"
source "$SCRIPT_DIR/util.sh"

CONFIG="${1:-configs/local.yml}"
# Resolve absolute path for config
if [[ ! "$CONFIG" = /* ]]; then
  CONFIG="$SCRIPT_DIR/../$CONFIG"
fi

DRY_RUN=${DRY_RUN:-false}
YES=${YES:-false}
LOG_LEVEL=${LOG_LEVEL:-info}

info "macOS installer starting (dry_run=${DRY_RUN})"

if [[ ! -f "$CONFIG" ]]; then
  info "Config file $CONFIG not found; falling back to defaults"
  CONFIG="$SCRIPT_DIR/../configs/defaults.yml"
fi

check_dependencies

# Install Homebrew if missing
if ! command -v brew >/dev/null 2>&1; then
  if [[ "$DRY_RUN" == "true" ]]; then
    info "DRY RUN: would install Homebrew"
  else
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)" || true
    fi
  fi
fi

# Determine clients
clients=$(get_config "$CONFIG" "macos.enable")

for client in $clients; do
  case "$client" in
    thunderbird)
      if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: brew install --cask thunderbird"
      else
        brew install --cask thunderbird || info "Thunderbird cask failed"
      fi
      ;;
    mailspring)
      if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: brew install --cask mailspring"
      else
        brew install --cask mailspring || info "Mailspring cask failed"
      fi
      ;;
    microsoft-outlook)
      if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: brew install --cask microsoft-outlook"
      else
        brew install --cask microsoft-outlook || info "Outlook cask failed"
      fi
      ;;
    spark)
      if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: brew install --cask spark"
      else
        brew install --cask spark || info "Spark cask failed"
      fi
      ;;
    mimestream)
      if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: brew install --cask mimestream"
      else
        brew install --cask mimestream || info "Mimestream cask failed"
      fi
      ;;
    *)
      info "Unknown client $client; skipping"
      ;;
  esac
done

info "macOS install complete"
