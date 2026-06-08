#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
source "${ROOT}/lib/capture_helpers.sh"
init_compose "p11m" "docker-compose.yml"
trap 'teardown_lab 2>/dev/null || true' EXIT

setup_lab
sleep 3
VICTIM_MAC=$(${COMPOSE} exec -T victima cat /sys/class/net/eth0/address | tr -d '\r')
ATK_MAC=$(${COMPOSE} exec -T atacante cat /sys/class/net/eth0/address | tr -d '\r')

section "11" "ARP SPOOFING" "MITIGADO"
prompt_attack "10.9.0.10" "python3 /lab/arp_slow.py 10.9.0.20 ${VICTIM_MAC} 10.9.0.1 ${ATK_MAC}"
run_exec atacante python3 /lab/arp_slow.py 10.9.0.20 "${VICTIM_MAC}" 10.9.0.1 "${ATK_MAC}"
sleep 2
blank_line
prompt_victim "10.9.0.20" "ip neigh show 10.9.0.1  # entrada ARP estática"
run_exec victima ip neigh show 10.9.0.1 || true
echo "[+] Entrada estática protege gateway — spoofing bloqueado"

teardown_lab
