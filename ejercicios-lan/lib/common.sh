#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TALLER_ROOT="$(cd "${ROOT}/.." && pwd)"

get_lan_ip() {
  ip -4 route get 1.1.1.1 2>/dev/null \
    | awk '{for (i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}'
}

get_lan_dev() {
  ip -4 route get 1.1.1.1 2>/dev/null \
    | awk '{for (i=1;i<=NF;i++) if ($i=="dev") {print $(i+1); exit}}'
}

zombie_alias_ip() {
  local base="${1:-$(get_lan_ip)}"
  local prefix="${base%.*}"
  echo "${prefix}.250"
}

open_ports() {
  if command -v firewall-cmd &>/dev/null && systemctl is-active --quiet firewalld 2>/dev/null; then
    for p in "$@"; do
      firewall-cmd --add-port="${p}" 2>/dev/null || true
    done
  fi
}

usage_ip() {
  local ip
  ip="$(get_lan_ip)"
  echo "IP LAN del servidor: ${ip}"
  echo "Pásala al atacante como: $1 ${ip}"
}
