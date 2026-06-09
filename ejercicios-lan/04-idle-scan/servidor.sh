#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

LAN_IP="$(get_lan_ip)"
LAN_DEV="$(get_lan_dev)"
ZOMBIE_IP="$(zombie_alias_ip "${LAN_IP}")"
PIDFILE_Z="/tmp/taller-lan-04-zombie.pid"
PIDFILE_T="/tmp/taller-lan-04-target.pid"
ALIAS_ADDED=0

cleanup() {
  [[ -f "${PIDFILE_Z}" ]] && kill "$(cat "${PIDFILE_Z}")" 2>/dev/null || true
  [[ -f "${PIDFILE_T}" ]] && kill "$(cat "${PIDFILE_T}")" 2>/dev/null || true
  rm -f "${PIDFILE_Z}" "${PIDFILE_T}"
  if [[ "${ALIAS_ADDED}" -eq 1 ]]; then
    sudo ip addr del "${ZOMBIE_IP}/24" dev "${LAN_DEV}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

echo "=== Punto 04 LAN — Zombie + Objetivo ==="
sudo sysctl -w net.ipv4.conf.all.rp_filter=0 >/dev/null 2>&1 || true
sudo sysctl -w net.ipv4.conf."${LAN_DEV}".rp_filter=0 >/dev/null 2>&1 || true
open_ports 8080/tcp

if ! ip -4 addr show dev "${LAN_DEV}" | grep -q "${ZOMBIE_IP}/"; then
  sudo ip addr add "${ZOMBIE_IP}/24" dev "${LAN_DEV}"
  ALIAS_ADDED=1
fi

sudo python3 "${TALLER_ROOT}/punto-04-idle-zombie-scan/vulnerable/scripts/zombie.py" &
echo $! > "${PIDFILE_Z}"

nc -lk 0.0.0.0 8080 >/dev/null 2>&1 &
echo $! > "${PIDFILE_T}"

echo "IP objetivo (puerto 8080):  ${LAN_IP}"
echo "IP zombie (alias):          ${ZOMBIE_IP}"
echo ""
echo "Atacante:"
echo "  sudo ./atacante.sh ${LAN_IP} ${ZOMBIE_IP}"
echo ""
echo "Ctrl+C para parar"

wait
