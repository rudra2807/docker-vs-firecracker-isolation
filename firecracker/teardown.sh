#!/usr/bin/env bash
# teardown.sh - undo networking setup (NAT + TAP) created by setup.sh

set -euo pipefail

TAP_DEV="${1:-fc-88-tap0}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

need_root() {
  [[ $EUID -eq 0 ]] || { echo "Run as root (use sudo): sudo $0 [tap-device]"; exit 1; }
}

main() {
  need_root

  # Disable NAT rules (safe if already disabled)
  if [[ -x "$SCRIPT_DIR/nat-toggle.sh" ]]; then
    "$SCRIPT_DIR/nat-toggle.sh" disable "$TAP_DEV" || true
  else
    echo "WARN: nat-toggle.sh not found or not executable; skipping NAT disable"
  fi

  # Bring the TAP interface down and delete it
  ip link set "$TAP_DEV" down 2>/dev/null || true
  ip link del "$TAP_DEV" 2>/dev/null || true

  echo "Teardown complete: NAT disabled (if present) and TAP device '$TAP_DEV' removed."
}

main

