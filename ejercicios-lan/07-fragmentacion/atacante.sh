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

echo "=== Punto 07 LAN — Ataque por fragmentación ==="
ping -c 1 "${SERVER}" || true
exec sudo python3 "${TALLER_ROOT}/punto-07-fragmentacion-ip/vulnerable/scripts/fragment_attack.py" "${SERVER}"
