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

MITIG_STATE="${MITIG_STATE:-/tmp/taller-lan-mitig}"

sysctl_save() {
  local key="$1" file="${MITIG_STATE}/$(echo "$key" | tr './' '__')"
  mkdir -p "${MITIG_STATE}"
  sysctl -n "${key}" > "${file}" 2>/dev/null || echo 0 > "${file}"
}

sysctl_set() {
  sudo sysctl -w "$1=$2" >/dev/null
}

sysctl_restore_all() {
  [[ -d "${MITIG_STATE}" ]] || return 0
  local f key val
  for f in "${MITIG_STATE}"/*; do
    [[ -f "${f}" ]] || continue
    key="$(basename "${f}" | tr '__' './')"
    val="$(cat "${f}")"
    sudo sysctl -w "${key}=${val}" >/dev/null 2>&1 || true
  done
  rm -rf "${MITIG_STATE}"
}

tc_jammer_on() {
  local dev="${1:-$(get_lan_dev)}"
  sudo tc qdisc del dev "${dev}" root 2>/dev/null || true
  sudo tc qdisc add dev "${dev}" root netem delay 100ms 50ms
  echo "[+] Jammer activo: tc netem delay 100ms 50ms en ${dev}"
}

tc_jammer_off() {
  local dev="${1:-$(get_lan_dev)}"
  sudo tc qdisc del dev "${dev}" root 2>/dev/null || true
}

iptables_icmp_tunnel_mitigation_on() {
  sudo iptables -C INPUT -p icmp --icmp-type echo-request -m length --length 85:65535 -j DROP 2>/dev/null \
    || sudo iptables -A INPUT -p icmp --icmp-type echo-request -m length --length 85:65535 -j DROP
  echo "[+] Mitigación: DROP ICMP echo-request length 85:65535"
}

iptables_icmp_tunnel_mitigation_off() {
  sudo iptables -D INPUT -p icmp --icmp-type echo-request -m length --length 85:65535 -j DROP 2>/dev/null || true
}

iptables_fragment_mitigation_on() {
  sudo iptables -t mangle -C PREROUTING -f -j DROP 2>/dev/null \
    || sudo iptables -t mangle -A PREROUTING -f -j DROP
  echo "[+] Mitigación: DROP fragmentos IP (mangle PREROUTING -f)"
}

iptables_fragment_mitigation_off() {
  sudo iptables -t mangle -D PREROUTING -f -j DROP 2>/dev/null || true
}
