#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

echo "=== Punto 07 LAN — Detector UDP :9999 ==="
open_ports 9999/udp
usage_ip "atacante.sh"
echo ""
echo "Escuchando fragmentos UDP (Ctrl+C para parar)..."
exec sudo python3 "${TALLER_ROOT}/punto-07-fragmentacion-ip/vulnerable/scripts/fragment_detect.py"
