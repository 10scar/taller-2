#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

LAN_DEV="$(get_lan_dev)"

cleanup() {
  tc_jammer_off "${LAN_DEV}"
}
trap cleanup EXIT

echo "=== Punto 02 LAN — MITIGADO (Receptor + jitter) ==="
tc_jammer_on "${LAN_DEV}"
usage_ip "atacante.sh"
echo ""
echo "Escuchando ICMP con jitter activo (Ctrl+C para parar)..."
exec sudo python3 "${TALLER_ROOT}/punto-02-canales-temporizacion/vulnerable/scripts/timing_recv.py"
