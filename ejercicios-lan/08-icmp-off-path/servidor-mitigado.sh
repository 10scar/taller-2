#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

LAN_IP="$(get_lan_ip)"
LAN_DEV="$(get_lan_dev)"
PIDFILE_S="/tmp/taller-lan-08-server.pid"
PIDFILE_V="/tmp/taller-lan-08-victim.pid"
STATE_DIR="/tmp/taller-lan-08-mitigado"
SPORT=45678
DPORT=8080

save_sysctl() {
  mkdir -p "${STATE_DIR}"
  sysctl -n net.ipv4.conf.all.accept_redirects > "${STATE_DIR}/all.accept_redirects" 2>/dev/null || echo 1 > "${STATE_DIR}/all.accept_redirects"
  sysctl -n net.ipv4.conf.default.accept_redirects > "${STATE_DIR}/default.accept_redirects" 2>/dev/null || echo 1 > "${STATE_DIR}/default.accept_redirects"
  sysctl -n net.ipv4.tcp_mtu_probing > "${STATE_DIR}/tcp_mtu_probing" 2>/dev/null || echo 0 > "${STATE_DIR}/tcp_mtu_probing"
  if [[ -n "${LAN_DEV}" ]]; then
    sysctl -n "net.ipv4.conf.${LAN_DEV}.accept_redirects" > "${STATE_DIR}/dev.accept_redirects" 2>/dev/null || echo 1 > "${STATE_DIR}/dev.accept_redirects"
  fi
}

apply_mitigation() {
  save_sysctl
  sudo sysctl -w net.ipv4.conf.all.accept_redirects=0 >/dev/null
  sudo sysctl -w net.ipv4.conf.default.accept_redirects=0 >/dev/null
  sudo sysctl -w net.ipv4.tcp_mtu_probing=1 >/dev/null
  if [[ -n "${LAN_DEV}" ]]; then
    sudo sysctl -w "net.ipv4.conf.${LAN_DEV}.accept_redirects=0" >/dev/null
  fi
  echo "[+] Mitigación activa: accept_redirects=0, tcp_mtu_probing=1 (${LAN_DEV})"
}

restore_sysctl() {
  [[ -d "${STATE_DIR}" ]] || return 0
  sudo sysctl -w "net.ipv4.conf.all.accept_redirects=$(cat "${STATE_DIR}/all.accept_redirects")" >/dev/null 2>&1 || true
  sudo sysctl -w "net.ipv4.conf.default.accept_redirects=$(cat "${STATE_DIR}/default.accept_redirects")" >/dev/null 2>&1 || true
  sudo sysctl -w "net.ipv4.tcp_mtu_probing=$(cat "${STATE_DIR}/tcp_mtu_probing")" >/dev/null 2>&1 || true
  if [[ -n "${LAN_DEV}" && -f "${STATE_DIR}/dev.accept_redirects" ]]; then
    sudo sysctl -w "net.ipv4.conf.${LAN_DEV}.accept_redirects=$(cat "${STATE_DIR}/dev.accept_redirects")" >/dev/null 2>&1 || true
  fi
  rm -rf "${STATE_DIR}"
}

cleanup() {
  [[ -f "${PIDFILE_S}" ]] && kill "$(cat "${PIDFILE_S}")" 2>/dev/null || true
  [[ -f "${PIDFILE_V}" ]] && kill "$(cat "${PIDFILE_V}")" 2>/dev/null || true
  rm -f "${PIDFILE_S}" "${PIDFILE_V}"
  restore_sysctl
}
trap cleanup EXIT

echo "=== Punto 08 LAN — MITIGADO (Servidor + Víctima) ==="
apply_mitigation
open_ports 8080/tcp

python3 "${TALLER_ROOT}/punto-08-icmp-off-path/vulnerable/scripts/tcp_server.py" &
echo $! > "${PIDFILE_S}"
sleep 1

python3 "${TALLER_ROOT}/punto-08-icmp-off-path/vulnerable/scripts/victim_demo.py" \
  "${LAN_IP}" "${DPORT}" 300 "${SPORT}" &
echo $! > "${PIDFILE_V}"

echo "IP LAN:     ${LAN_IP}"
echo "Servidor:   http://${LAN_IP}:${DPORT}/"
echo "Víctima:    TCP ${SPORT} -> ${LAN_IP}:${DPORT} (300s)"
echo ""
echo "Atacante (mismo comando que vulnerable):"
echo "  curl http://${LAN_IP}:${DPORT}/"
echo "  sudo ./atacante.sh ${LAN_IP}"
echo ""
echo "Verificar (servidor, tras ataque — MTU NO debe quedar en 576):"
echo "  ip route get ${LAN_IP}"
echo ""
echo "Ctrl+C para parar (restaura sysctl)"

wait
