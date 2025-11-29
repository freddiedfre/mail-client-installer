#!/usr/bin/env bash
# Install mail clients on Debian/Ubuntu
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

info "Ubuntu/Debian installer starting (dry_run=${DRY_RUN})"

if [[ ! -f "$CONFIG" ]]; then
  info "Config file $CONFIG not found; falling back to defaults"
  CONFIG="$SCRIPT_DIR/../configs/defaults.yml"
fi

check_dependencies

# Helper: install apt package if not present
install_apt_pkg() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    info "$pkg already installed"
    return
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    info "DRY RUN: would apt install $pkg"
    return
  fi
  info "Installing apt package: $pkg"
  sudo apt-get install -y --no-install-recommends "$pkg"
}

if [[ "$DRY_RUN" == "true" ]]; then
  info "DRY RUN: would sudo apt-get update -y"
else
  sudo apt-get update -y
fi

# Determine list from config
clients=$(get_config "$CONFIG" "linux.enable")

for client in $clients; do
  case "$client" in
    thunderbird)
      install_apt_pkg thunderbird
      ;;
    evolution)
      install_apt_pkg evolution
      ;;
    kmail)
      install_apt_pkg kmail || info "kmail may not be present on non-kde systems"
      ;;
    mutt)
      install_apt_pkg mutt
      ;;
    neomutt)
      install_apt_pkg neomutt
      ;;
    alpine)
      install_apt_pkg alpine
      ;;
    mailspring)
      mailspring_url=$(get_config "$CONFIG" "linux.mailspring.url")
      if [[ -z "$mailspring_url" ]]; then
        info "Mailspring URL not configured; skipping"
        continue
      fi
      TMP_DEB=$(mktemp --suffix=.deb)
      info "Downloading Mailspring to $TMP_DEB"
      if [[ "$DRY_RUN" == "true" ]]; then
        info "DRY RUN: would download $mailspring_url"
      else
        download "$mailspring_url" "$TMP_DEB"
        checksum=$(get_config "$CONFIG" "linux.mailspring.checksum")
        if [[ -n "$checksum" ]]; then
          verify_checksum "$TMP_DEB" "$checksum"
        fi
        sudo dpkg -i "$TMP_DEB" || sudo apt --fix-broken install -y
        rm -f "$TMP_DEB"
      fi
      ;;
    *)
      info "Unknown client $client; skipping"
      ;;
  esac
done

# Optional Flatpak
flatpak_enable=$(get_config "$CONFIG" "linux.flatpak.enable" "false")
if [[ "$flatpak_enable" == "true" ]]; then
  if ! command -v flatpak >/dev/null 2>&1; then
    info "Flatpak not installed; installing flatpak"
    if [[ "$DRY_RUN" == "true" ]]; then
      info "DRY RUN: would apt install flatpak"
    else
      sudo apt-get install -y flatpak
    fi
  fi
  if [[ "$DRY_RUN" == "true" ]]; then
    info "DRY RUN: would flatpak install flathub org.mozilla.Thunderbird"
  else
    # Check if remote exists, add if not
    if ! flatpak remote-list | grep -q flathub; then
       flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi
    flatpak install -y flathub org.mozilla.Thunderbird || info "flatpak install may have failed"
  fi
fi

info "Ubuntu/Debian install complete"
