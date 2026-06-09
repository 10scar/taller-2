#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

SERVER="${1:-}"
if [[ -z "${SERVER}" ]]; then
  echo "Uso: ./atacante.sh <IP_SERVIDOR>"
  echo "  Terminal 1: (echo sesion; sleep 120) | nc <IP> 9999"
  echo "  Terminal 2: sudo ./atacante.sh <IP>"
  exit 1
fi

echo "=== Punto 03 LAN — Challenge ACK probe ==="
echo "[!] Mantén una sesión activa: (echo sesion; sleep 120) | nc ${SERVER} 9999"
read -r -p "Pulsa Enter cuando la sesión esté abierta..."
exec sudo python3 "${TALLER_ROOT}/punto-03-tcp-session-hijacking/vulnerable/scripts/challenge_ack_probe.py" "${SERVER}"
