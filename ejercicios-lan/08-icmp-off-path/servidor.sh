#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

LAN_IP="$(get_lan_ip)"
PIDFILE_S="/tmp/taller-lan-08-server.pid"
PIDFILE_V="/tmp/taller-lan-08-victim.pid"
SPORT=45678
DPORT=8080

cleanup() {
  [[ -f "${PIDFILE_S}" ]] && kill "$(cat "${PIDFILE_S}")" 2>/dev/null || true
  [[ -f "${PIDFILE_V}" ]] && kill "$(cat "${PIDFILE_V}")" 2>/dev/null || true
  rm -f "${PIDFILE_S}" "${PIDFILE_V}"
}
trap cleanup EXIT

echo "=== Punto 08 LAN — Servidor + Víctima ==="
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
echo "Atacante:"
echo "  curl http://${LAN_IP}:${DPORT}/"
echo "  sudo ./atacante.sh ${LAN_IP}"
echo ""
echo "Verificar MTU (servidor, tras ataque):"
echo "  ip route get ${LAN_IP}"
echo ""
echo "Ctrl+C para parar"

wait
