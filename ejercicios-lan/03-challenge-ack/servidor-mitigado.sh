#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

PIDFILE="/tmp/taller-lan-03-nc.pid"

cleanup() {
  [[ -f "${PIDFILE}" ]] && kill "$(cat "${PIDFILE}")" 2>/dev/null || true
  rm -f "${PIDFILE}"
  sysctl_restore_all
}
trap cleanup EXIT

echo "=== Punto 03 LAN — MITIGADO (TCP :9999) ==="
sysctl_save net.ipv4.tcp_challenge_ack_limit
sysctl_set net.ipv4.tcp_challenge_ack_limit 2147483647
echo "[+] Mitigación: tcp_challenge_ack_limit=2147483647"

open_ports 9999/tcp
usage_ip "atacante.sh"

nc -lk 0.0.0.0 9999 &
echo $! > "${PIDFILE}"
echo "Servidor nc en 0.0.0.0:9999 (Ctrl+C para parar)"
wait
