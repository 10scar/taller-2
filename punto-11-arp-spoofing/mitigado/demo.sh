#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 11 — ARP SPOOFING [MITIGADO] =========="
P="docker compose -p p11m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 3
VICTIM_MAC=$($P exec victima cat /sys/class/net/eth0/address | tr -d '\r')
ATK_MAC=$($P exec atacante cat /sys/class/net/eth0/address | tr -d '\r')
$P exec atacante python3 /lab/arp_slow.py 10.9.0.20 "$VICTIM_MAC" 10.9.0.1 "$ATK_MAC"
sleep 1
echo "[*] Tabla ARP víctima (entrada estática protegida):"
$P exec victima ip neigh show 10.9.0.1 || true
$P down -v
