#!/usr/bin/env bash
#
# nat-toggle.sh
# Enable or disable source-NAT so Firecracker microVMs can reach the Internet.
#
# Usage:
#   sudo ./nat-toggle.sh enable  fc-88-tap0        # turn NAT on
#   sudo ./nat-toggle.sh disable fc-88-tap0        # turn NAT off
#
set -euo pipefail

ACTION=${1:-}
TAP_DEV=${2:-fc-88-tap0}           # default matches setup.sh
GUEST_NET=169.254.0.20/30          # /30 subnet used inside the VM
OUT_IF=$(ip route | awk '$1=="default"{print $5;exit}')

need_root() {
  [[ $EUID -eq 0 ]] || { echo "Run as root (use sudo)"; exit 1; }
}

rule_exist() {
  iptables -t nat -C POSTROUTING -s "$GUEST_NET" -o "$OUT_IF" -j MASQUERADE 2>/dev/null
}

enable_nat() {
  # 1. allow forwarding
  sysctl -w net.ipv4.ip_forward=1 >/dev/null

  # 2. add rules if they are not already present
  if ! rule_exist; then
    iptables -t nat -A POSTROUTING -s "$GUEST_NET" -o "$OUT_IF" -j MASQUERADE
    iptables -A FORWARD -i "$OUT_IF" -o "$TAP_DEV" -m conntrack \
            --ctstate RELATED,ESTABLISHED -j ACCEPT
    iptables -A FORWARD -i "$TAP_DEV" -o "$OUT_IF" -j ACCEPT
    echo "NAT enabled for $TAP_DEV -> $OUT_IF"
  else
    echo "NAT already enabled"
  fi
}

disable_nat() {
  # delete rules only if they exist
  if rule_exist; then
    iptables -t nat -D POSTROUTING -s "$GUEST_NET" -o "$OUT_IF" -j MASQUERADE
    iptables -D FORWARD -i "$OUT_IF" -o "$TAP_DEV" -m conntrack \
            --ctstate RELATED,ESTABLISHED -j ACCEPT || true
    iptables -D FORWARD -i "$TAP_DEV" -o "$OUT_IF" -j ACCEPT || true
    echo "NAT disabled for $TAP_DEV"
  else
    echo "NAT already disabled"
  fi

  # Optionally turn IP forwarding back off if no other rules rely on it
  if ! iptables -t nat -S | grep -q MASQUERADE; then
    sysctl -w net.ipv4.ip_forward=0 >/dev/null
  fi
}

main() {
  need_root
  case "$ACTION" in
    enable)  enable_nat ;;
    disable) disable_nat ;;
    *) echo "Usage: sudo $0 {enable|disable} [tap-device]"; exit 1 ;;
  esac
}

main

