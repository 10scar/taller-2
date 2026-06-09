#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

TARGET="${1:-}"
ZOMBIE="${2:-}"
if [[ -z "${TARGET}" || -z "${ZOMBIE}" ]]; then
  echo "Uso: sudo ./atacante.sh <IP_OBJETIVO> <IP_ZOMBIE>"
  echo "  El servidor imprime ambas IPs al arrancar."
  exit 1
fi

echo "=== Punto 04 LAN — Idle scan ==="
ping -c 1 "${TARGET}" || true
ping -c 1 "${ZOMBIE}" || true
echo test | nc -w 2 "${TARGET}" 8080 || true
exec sudo python3 "${TALLER_ROOT}/punto-04-idle-zombie-scan/vulnerable/scripts/idle_scan.py" \
  "${ZOMBIE}" "${TARGET}" 8080
