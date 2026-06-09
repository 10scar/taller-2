#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

SERVER="${1:-}"
MSG="${2:-MensajeSecretoTunelizado}"
if [[ -z "${SERVER}" ]]; then
  echo "Uso: sudo ./atacante.sh <IP_SERVIDOR> [mensaje]"
  exit 1
fi

echo "=== Punto 05 LAN — Emisor ICMP ==="
ping -c 1 "${SERVER}" || true
exec sudo python3 "${TALLER_ROOT}/punto-05-icmp-tunneling/vulnerable/scripts/send_icmp.py" \
  "${SERVER}" "${MSG}"
