#!/usr/bin/env bash
set -euo pipefail
echo "========== PUNTO 08 — ICMP OFF-PATH [MITIGADO] =========="
P="docker compose -p p08m -f docker-compose.yml"
trap '$P down -v 2>/dev/null || true' EXIT
$P down -v 2>/dev/null || true
$P up -d --build
sleep 3
$P exec -d servidor python3 /lab/tcp_server.py
sleep 1
$P exec -d victima python3 /lab/victim_demo.py 10.9.0.30 8080 14 45678
sleep 2
$P exec atacante python3 /lab/forge_icmp_mtu.py 10.9.0.20 10.9.0.20 10.9.0.30 45678 8080 1 576
sleep 12
$P logs victima 2>/dev/null | tail -20 || true
$P down -v
