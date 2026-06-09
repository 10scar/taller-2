#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

SERVER="${1:-}"
if [[ -z "${SERVER}" ]]; then
  echo "Uso: sudo ./atacante.sh <IP_SERVIDOR>"
  exit 1
fi

echo "=== Punto 02 LAN — Emisor (timing) ==="
ping -c 1 "${SERVER}" || true
exec sudo python3 "${TALLER_ROOT}/punto-02-canales-temporizacion/vulnerable/scripts/timing_send.py" "${SERVER}" 1010
