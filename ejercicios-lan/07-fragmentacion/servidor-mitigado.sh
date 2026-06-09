#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

cleanup() {
  iptables_fragment_mitigation_off
}
trap cleanup EXIT

echo "=== Punto 07 LAN — MITIGADO (Detector UDP :9999) ==="
iptables_fragment_mitigation_on
open_ports 9999/udp
usage_ip "atacante.sh"
echo ""
echo "Escuchando UDP (fragmentos IP descartados por iptables)..."
exec sudo python3 "${TALLER_ROOT}/punto-07-fragmentacion-ip/vulnerable/scripts/fragment_detect.py"
