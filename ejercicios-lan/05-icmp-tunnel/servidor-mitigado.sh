#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=../lib/common.sh
source "${DIR}/../lib/common.sh"

cleanup() {
  iptables_icmp_tunnel_mitigation_off
}
trap cleanup EXIT

echo "=== Punto 05 LAN — MITIGADO (Receptor ICMP) ==="
iptables_icmp_tunnel_mitigation_on
usage_ip "atacante.sh"
echo ""
echo "Escuchando ICMP (paquetes largos bloqueados por iptables)..."
exec sudo python3 "${TALLER_ROOT}/punto-05-icmp-tunneling/vulnerable/scripts/recv_icmp.py"
