#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

echo "=== Punto 05 LAN — Receptor ICMP ==="
usage_ip "atacante.sh"
echo ""
echo "Escuchando ICMP tunelizado (Ctrl+C para parar)..."
exec sudo python3 "${TALLER_ROOT}/punto-05-icmp-tunneling/vulnerable/scripts/recv_icmp.py"
