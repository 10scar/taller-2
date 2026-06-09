#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

echo "=== Punto 02 LAN — Receptor (timing) ==="
usage_ip "atacante.sh"
echo ""
echo "Escuchando ICMP (Ctrl+C para parar)..."
exec sudo python3 "${TALLER_ROOT}/punto-02-canales-temporizacion/vulnerable/scripts/timing_recv.py"
